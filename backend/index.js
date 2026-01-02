// index.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const pool = require('./db');
const usersRouter = require('./routes/users');
const hospitalsRouter = require('./routes/hospitals');
const ridesRouter = require('./routes/rides');
const appointmentsRouter = require('./routes/appointments');
const doctorsRoutes = require('./routes/doctors');
const authMiddleware = require('./middleware/auth');
const medicalReportsRouter = require('./routes/medical-reports');

const app = express();

// ---------- GLOBAL MIDDLEWARE (MUST BE IN THIS ORDER) ----------
app.use(cors());
app.use(express.json({ limit: '50mb' })); // ✅ Increase limit
app.use(express.urlencoded({ extended: true, limit: '50mb' })); // ✅ Add this
app.use('/uploads', express.static('uploads'));

// Simple query helper
async function query(text, params) {
  const res = await pool.query(text, params);
  return res;
}

// ---------- USER PROFILE: GET /users/me ----------

// ✅ Add this route if you don't have it
// index.js or routes/users.js

// ✅ GET /users/me - COMPLETE VERSION
app.get('/users/me', authMiddleware, async (req, res) => {
  console.log('📡 GET /users/me called');
  console.log('   User ID:', req.user.id);
  
  try {
    const userId = req.user.id;

    // ✅ Query with LEFT JOIN to get doctor data
    const result = await pool.query(
      `SELECT 
        u.id,
        u.name,
        u.email,
        u.role,
        u.profile_picture,
        d.specialization,
        d.experience_years,
        d.about,
        d.verified,
        h.id as hospital_id,
        h.name as hospital_name,
        h.address as hospital_address,
        h.city as hospital_city,
        h.latitude,
        h.longitude
       FROM users u
       LEFT JOIN doctors d ON u.id = d.user_id
       LEFT JOIN hospitals h ON d.hospital_id = h.id
       WHERE u.id = $1`,
      [userId]
    );

    console.log('📊 Query result:', result.rows);

    if (result.rows.length === 0) {
      console.error('❌ User not found');
      return res.status(404).json({ error: 'User not found' });
    }

    const user = result.rows[0];

    console.log('✅ Raw user data:');
    console.log('   Name:', user.name);
    console.log('   Role:', user.role);
    console.log('   Specialization:', user.specialization);
    console.log('   Experience:', user.experience_years);
    console.log('   Hospital ID:', user.hospital_id);
    console.log('   Hospital Name:', user.hospital_name);

    // ✅ Build response
    const response = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      profile_picture: user.profile_picture,
      profile_picture_url: user.profile_picture 
        ? `/uploads/profile-pictures/${user.profile_picture}`
        : null,
      specialization: user.specialization,
      experience_years: user.experience_years,
      about: user.about,
      verified: user.verified,
      selected_hospital_id: user.hospital_id,
      selected_hospital_name: user.hospital_name,
      hospital: user.hospital_id ? {
        id: user.hospital_id,
        name: user.hospital_name,
        address: user.hospital_address,
        city: user.hospital_city,
        latitude: user.latitude,
        longitude: user.longitude,
      } : null,
    };

    console.log('✅ Sending response:', response);

    res.json({ user: response });
  } catch (e) {
    console.error('❌ GET /users/me error:', e);
    res.status(500).json({ error: 'Server error' });
  }
});



// ---------- AUTH ----------

// ✅ POST /auth/register
app.post('/auth/register', async (req, res) => {
  console.log('📝 Register request received');
  console.log('Body:', req.body);

  try {
    const { name, email, password, role, hospitalName } = req.body;

    // ✅ Validate input
    if (!name || !email || !password || !role) {
      console.error('❌ Missing fields:', { name, email, password: '***', role });
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (!['patient', 'doctor', 'admin', 'driver'].includes(role)) {
      console.error('❌ Invalid role:', role);
      return res.status(400).json({ error: 'Invalid role' });
    }

    // Check if user exists
    const existingUser = await query(
      'SELECT id FROM users WHERE email = $1',
      [email.toLowerCase()]
    );

    if (existingUser.rows.length > 0) {
      console.error('❌ Email already exists:', email);
      return res.status(400).json({ error: 'Email already in use' });
    }

    // Hash password
    const hash = await bcrypt.hash(password, 10);

    // Create user
    const userRes = await query(
      'INSERT INTO users(name, email, password_hash, role) VALUES ($1,$2,$3,$4) RETURNING id, name, email, role, profile_picture',
      [name, email.toLowerCase(), hash, role]
    );
    const user = userRes.rows[0];

    console.log(`✅ User created: ${user.email} (ID: ${user.id}, Role: ${user.role})`);

    // ✅ Handle doctor role
    if (role === 'doctor') {
      if (hospitalName) {
        // Legacy flow with hospital name
        let hospRes = await query(
          'SELECT id FROM hospitals WHERE name = $1',
          [hospitalName]
        );
        
        let hospitalId;
        if (hospRes.rows.length === 0) {
          hospRes = await query(
            'INSERT INTO hospitals(name) VALUES ($1) RETURNING id',
            [hospitalName]
          );
          hospitalId = hospRes.rows[0].id;
          console.log(`✅ Hospital created: ${hospitalName} (ID: ${hospitalId})`);
        } else {
          hospitalId = hospRes.rows[0].id;
          console.log(`✅ Hospital found: ${hospitalName} (ID: ${hospitalId})`);
        }

        await query(
          `INSERT INTO doctors (user_id, hospital_id)
           VALUES ($1, $2)
           ON CONFLICT (user_id) DO UPDATE SET hospital_id = EXCLUDED.hospital_id`,
          [user.id, hospitalId]
        );
        console.log(`✅ Doctor linked to hospital: ${hospitalId}`);
      } else {
        // ✅ NEW: Create doctor WITHOUT hospital (hospital_id can be NULL)
        await query(
          'INSERT INTO doctors (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING',
          [user.id]
        );
        console.log(`✅ Doctor entry created without hospital`);
      }
    }

    // Generate token
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'dev-secret',
      { expiresIn: '7d' }
    );

    // Build user response
    const userResponse = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      profile_picture: user.profile_picture,
      profile_picture_url: user.profile_picture 
        ? `/uploads/profile-pictures/${user.profile_picture}`
        : null,
      selected_hospital_id: null,
      selected_hospital_name: null,
      hospital: null,
    };

    console.log(`✅ Registration successful: ${user.email}`);

    res.status(201).json({ 
      success: true,
      token, 
      user: userResponse 
    });
  } catch (e) {
    console.error('❌ Registration error:', e);
    if (e.code === '23505') {
      return res.status(400).json({ error: 'Email already in use' });
    }
    if (e.code === '23502') {
      return res.status(500).json({ error: 'Database constraint error. Please contact support.' });
    }
    res.status(500).json({ error: 'Server error: ' + e.message });
  }
});

// ✅ POST /auth/login - WITH HOSPITAL DATA
app.post('/auth/login', async (req, res) => {
  console.log('🔐 Login request received');
  console.log('Body:', { email: req.body.email, password: '***' });

  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    const userRes = await query(
      'SELECT * FROM users WHERE email = $1',
      [email.toLowerCase()]
    );
    
    if (userRes.rows.length === 0) {
      console.error('❌ User not found:', email);
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const user = userRes.rows[0];
    const ok = await bcrypt.compare(password, user.password_hash);
    
    if (!ok) {
      console.error('❌ Invalid password for:', email);
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Generate token
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'dev-secret',
      { expiresIn: '7d' }
    );

    // Get hospital data if doctor
    let hospitalData = null;
    if (user.role === 'doctor') {
      const hospitalResult = await query(
        `SELECT h.id, h.name, h.address, h.city, h.latitude, h.longitude
         FROM doctors d
         JOIN hospitals h ON d.hospital_id = h.id
         WHERE d.user_id = $1`,
        [user.id]
      );

      if (hospitalResult.rows.length > 0) {
        hospitalData = hospitalResult.rows[0];
        console.log(`✅ Doctor has hospital: ${hospitalData.name}`);
      } else {
        console.log(`⚠️ Doctor has NO hospital selected`);
      }
    }

    // Build complete user response
    const userResponse = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      profile_picture: user.profile_picture,
      profile_picture_url: user.profile_picture 
        ? `/uploads/profile-pictures/${user.profile_picture}`
        : null,
      selected_hospital_id: hospitalData?.id || null,
      selected_hospital_name: hospitalData?.name || null,
      hospital: hospitalData,
    };

    console.log(`✅ Login successful: ${user.email} (${user.role})`);

    res.json({
      success: true,
      token,
      user: userResponse,
    });
  } catch (e) {
    console.error('❌ Login error:', e);
    res.status(500).json({ error: 'Server error: ' + e.message });
  }
});

// ---------- ROUTES ----------

app.use('/users', usersRouter);
app.use('/password-reset', require('./routes/password-reset')); 
app.use('/hospitals', hospitalsRouter);
app.use('/rides', ridesRouter);
app.use('/appointments', appointmentsRouter);
app.use('/verification', require('./routes/verification')); 
app.use('/doctors', doctorsRoutes);
app.use('/medical-reports', authMiddleware, medicalReportsRouter);

// ---------- SERVER BOOT ----------

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`✅ API running on http://localhost:${PORT}`);
  console.log(`✅ Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('📋 Available endpoints:');
  console.log('   POST /auth/register');
  console.log('   POST /auth/login');
  console.log('   POST /doctors/select-hospital');
  console.log('   GET  /doctors/my-hospital');
});
