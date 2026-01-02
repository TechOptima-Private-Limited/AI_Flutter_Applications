-- users table
CREATE TABLE users (
  id              SERIAL PRIMARY KEY,
  name            VARCHAR(100) NOT NULL,
  email           VARCHAR(150) UNIQUE NOT NULL,
  password_hash   TEXT NOT NULL,
  role            VARCHAR(20) NOT NULL,   -- 'patient' | 'doctor' | 'admin'
  specialization  VARCHAR(100),          -- for doctors
  hospital_name   VARCHAR(150),
  experience_years INTEGER,
  about           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- hospitals table
CREATE TABLE hospitals (
  id         SERIAL PRIMARY KEY,
  name       VARCHAR(150) NOT NULL,
  address    TEXT,
  latitude   DOUBLE PRECISION,
  longitude  DOUBLE PRECISION,
  phone      VARCHAR(30),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- doctors table (link doctors to users + hospitals)
CREATE TABLE doctors (
  id           SERIAL PRIMARY KEY,
  user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  hospital_id  INTEGER REFERENCES hospitals(id) ON DELETE SET NULL,
  specialty    VARCHAR(100),
  experience   INTEGER,
  rating       NUMERIC(3,2) DEFAULT 0.0,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);
-- appointments table
CREATE TABLE appointments (
  id           SERIAL PRIMARY KEY,
  user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  doctor_id    INTEGER NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  hospital_id  INTEGER REFERENCES hospitals(id) ON DELETE SET NULL,
  status       VARCHAR(20) NOT NULL,     -- 'pending' | 'confirmed' | 'completed' | 'cancelled'
  scheduled_at TIMESTAMPTZ,             -- when the visit is scheduled
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);
-- doctor_reviews table
CREATE TABLE doctor_reviews (
  id            SERIAL PRIMARY KEY,
  doctor_id     INTEGER NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  patient_name  VARCHAR(100) NOT NULL,
  rating        INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment       TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE hospital_doctors (
  user_id     INT REFERENCES users(id) ON DELETE CASCADE,
  hospital_id INT REFERENCES hospitals(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, hospital_id)
);
