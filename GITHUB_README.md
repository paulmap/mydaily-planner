# myDaily Planner 📅

A modern, beautifully designed daily todo app with calendar-based planning, SQLite storage, and Material 3 design.

## ✨ Features

- **📅 Interactive Calendar**: Plan tasks for any date (past, present, or future)
- **📝 Smart Task Management**: Add, edit, complete, and delete tasks
- **🔒 Past Date Protection**: View-only mode for historical data integrity
- **📄 PDF Export**: Download tasks for any date range as formatted PDFs
- **🎨 Modern UI**: Material 3 design with smooth animations
- **💾 Local Storage**: SQLite database for offline functionality
- **📱 Responsive Design**: Optimized for all screen sizes

## 🚀 Download & Install

### Android APK (Recommended)

Choose the APK that matches your device:

| APK File | Size | Architecture | Devices |
|---------|------|--------------|----------|
| [app-release.apk](https://github.com/paulmap/mydaily-planner/releases/latest/download/app-release.apk) | 54.9 MB | Universal | All devices |
| [app-arm64-v8a-release.apk](https://github.com/paulmap/mydaily-planner/releases/latest/download/app-arm64-v8a-release.apk) | 22.2 MB | ARM64 | Modern devices |
| [app-armeabi-v7a-release.apk](https://github.com/paulmap/mydaily-planner/releases/latest/download/app-armeabi-v7a-release.apk) | 19.8 MB | ARM32 | Older devices |
| [app-x86_64-release.apk](https://github.com/paulmap/mydaily-planner/releases/latest/download/app-x86_64-release.apk) | 23.6 MB | x64 | Emulators/tablets |

### Installation Instructions

1. **Enable Unknown Sources**: Go to Settings → Security → Install from unknown sources
2. **Download APK**: Click one of the links above
3. **Install**: Tap the downloaded APK file
4. **Enjoy**: Launch myDaily Planner!

### Web Version

Access to app directly in your browser:  
🌐 [https://paulmap.github.io/mydaily-planner](https://paulmap.github.io/mydaily-planner)

## 📱 Screenshots

*Add screenshots of your app here*

## 🎯 How to Use

### Calendar Planning
1. **Open Calendar**: The app starts with an interactive calendar
2. **Select Date**: Tap any date to view/create tasks
3. **Plan Tasks**: Add tasks for future dates, review past dates

### Task Management
- **Today's Tasks**: Quick access from the "Today" tab
- **All Lists**: Chronological view with PDF export
- **Status Updates**: Mark tasks as complete/incomplete

### Past Date Restrictions
- **View Only**: Past dates are read-only for data integrity
- **Status Updates**: Only completion status can be changed
- **Visual Indicators**: Clear "Read Only" badges

## 🛠️ Technical Details

- **Framework**: Flutter 3.x
- **Database**: SQLite (sqflite package)
- **PDF Generation**: pdf & printing packages
- **Design**: Material 3 with dynamic theming
- **Architecture**: Clean architecture with separation of concerns

## 📦 Build Instructions

```bash
# Clone the repository
git clone https://github.com/paulmap/mydaily-planner.git
cd mydaily-planner

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build APK for distribution
flutter build apk --release

# Build split APKs (smaller files)
flutter build apk --split-per-abi --release

# Build for web
flutter build web --release
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

If you have any questions or feedback:

- 📧 Email: paul.maposa@gmail.com
- 🐛 Report Issues: [GitHub Issues](https://github.com/paulmap/mydaily-planner/issues)
- 💬 Discussion: [GitHub Discussions](https://github.com/paulmap/mydaily-planner/discussions)

## 🌟 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the beautiful design system
- All contributors who help improve this project

---

**Made with ❤️ using Flutter**
