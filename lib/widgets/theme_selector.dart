// // lib/widgets/theme_selector.dart (UPDATED)
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../main.dart'; // Import ThemeNotifier
//
// class ThemeSelector extends StatelessWidget {
//   const ThemeSelector({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final notifier = Provider.of<ThemeNotifier>(context);
//
//     return PopupMenuButton<ThemeMode>(
//       icon: Icon(
//         _getThemeIcon(notifier.mode),
//         color: Theme.of(context).colorScheme.primary,
//       ),
//       tooltip: 'Theme',
//       onSelected: (m) => notifier.setMode(m),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       itemBuilder: (ctx) => <PopupMenuEntry<ThemeMode>>[
//         PopupMenuItem(
//           value: ThemeMode.system,
//           child: Row(
//             children: [
//               Icon(
//                 Icons.phone_android,
//                 color: notifier.mode == ThemeMode.system
//                     ? Theme.of(context).colorScheme.primary
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'System',
//                 style: TextStyle(
//                   fontWeight: notifier.mode == ThemeMode.system
//                       ? FontWeight.bold
//                       : FontWeight.normal,
//                   color: notifier.mode == ThemeMode.system
//                       ? Theme.of(context).colorScheme.primary
//                       : null,
//                 ),
//               ),
//               if (notifier.mode == ThemeMode.system) ...[
//                 const Spacer(),
//                 Icon(
//                   Icons.check,
//                   color: Theme.of(context).colorScheme.primary,
//                   size: 20,
//                 ),
//               ],
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: ThemeMode.light,
//           child: Row(
//             children: [
//               Icon(
//                 Icons.wb_sunny,
//                 color: notifier.mode == ThemeMode.light
//                     ? Theme.of(context).colorScheme.primary
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Light',
//                 style: TextStyle(
//                   fontWeight: notifier.mode == ThemeMode.light
//                       ? FontWeight.bold
//                       : FontWeight.normal,
//                   color: notifier.mode == ThemeMode.light
//                       ? Theme.of(context).colorScheme.primary
//                       : null,
//                 ),
//               ),
//               if (notifier.mode == ThemeMode.light) ...[
//                 const Spacer(),
//                 Icon(
//                   Icons.check,
//                   color: Theme.of(context).colorScheme.primary,
//                   size: 20,
//                 ),
//               ],
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: ThemeMode.dark,
//           child: Row(
//             children: [
//               Icon(
//                 Icons.nights_stay,
//                 color: notifier.mode == ThemeMode.dark
//                     ? Theme.of(context).colorScheme.primary
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Dark',
//                 style: TextStyle(
//                   fontWeight: notifier.mode == ThemeMode.dark
//                       ? FontWeight.bold
//                       : FontWeight.normal,
//                   color: notifier.mode == ThemeMode.dark
//                       ? Theme.of(context).colorScheme.primary
//                       : null,
//                 ),
//               ),
//               if (notifier.mode == ThemeMode.dark) ...[
//                 const Spacer(),
//                 Icon(
//                   Icons.check,
//                   color: Theme.of(context).colorScheme.primary,
//                   size: 20,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   IconData _getThemeIcon(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return Icons.wb_sunny;
//       case ThemeMode.dark:
//         return Icons.nights_stay;
//       case ThemeMode.system:
//       default:
//         return Icons.brightness_auto;
//     }
//   }
// }
