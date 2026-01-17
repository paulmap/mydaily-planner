# myDaily Planner

A modern, beautifully designed daily todo app with SQLite storage and Material 3 design.

## Features

- **Modern UI**: Material 3 design with smooth animations and thoughtful interactions
- **Calendar View**: Interactive calendar to plan tasks for any date (past, present, or future)
- **Daily Todo Lists**: Automatically creates a todo list for the current day when you open the app
- **Inline Editing**: Tap any task to edit it directly in place
- **Smart Navigation**: Modern bottom navigation with smooth transitions
- **Progress Tracking**: Visual completion counter in the app bar
- **Date Navigation**: View and edit todo lists for any date
- **Task Management**: Add, edit, complete, and delete tasks with intuitive gestures
- **PDF Export**: Download tasks for any date range as formatted PDF documents
- **Local Storage**: Uses SQLite database for offline storage
- **Responsive Design**: Optimized for all screen sizes

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone or download this project
2. Run `flutter pub get` to install dependencies
3. Connect a device or start an emulator
4. Run `flutter run` to start the app

### Dependencies

- `sqflite`: SQLite database plugin
- `path`: Path manipulation utilities
- `intl`: Internationalization and date formatting
- `pdf`: PDF generation and manipulation
- `printing`: PDF printing and sharing functionality

## App Structure

```
lib/
├── main.dart                 # App entry point with modern theme
├── models/
│   ├── todo_list.dart       # TodoList data model
│   └── todo_item.dart       # TodoItem data model
├── services/
│   ├── database_helper.dart # SQLite database operations
│   └── pdf_export_service.dart # PDF export functionality
└── screens/
    ├── calendar_screen.dart    # Interactive calendar for date selection and planning
    ├── todo_list_screen.dart    # Daily task list with modern UI
    └── date_list_screen.dart    # All todo lists with modern UI and PDF export
```

## Usage

1. **Calendar View**: The app opens to an interactive calendar showing all your task dates
2. **Plan Future Tasks**: Tap any date (past, present, or future) to create or edit tasks for that day
3. **Today's List**: Switch to "Today" tab for quick access to current day's tasks
4. **Add Tasks**: Type in the modern input field and press Enter or click the + button
5. **Edit Tasks**: Tap on any task text to edit it inline
6. **Complete Tasks**: Check the checkbox next to a task to mark it complete
7. **Delete Tasks**: Click the delete icon to remove a task
8. **View All Lists**: Switch to the "All Lists" tab to see a chronological view of all task dates
9. **Export to PDF**: In the "All Lists" screen, tap the menu button (⋮) and select "Export to PDF" to download tasks for any date range

## Calendar Features

The calendar view provides a powerful planning interface:

- **Visual Date Selection**: Tap any date to view and edit tasks for that specific day
- **Task Indicators**: Dates with existing tasks show a colored dot indicator
- **Today Highlighting**: Current date is clearly highlighted in calendar
- **Month Navigation**: Easy navigation between different months
- **Future Planning**: Select future dates to plan tasks ahead of time
- **Past Review**: Access previous days to review completed tasks (read-only)

## Past Date Restrictions

To maintain data integrity and historical accuracy:

- **Past dates are view-only**: You can review past tasks but cannot modify them
- **Status updates only**: Task completion status can be toggled for past dates
- **No task creation**: New tasks cannot be added to past dates
- **No editing**: Task titles cannot be edited for past dates
- **No deletion**: Tasks cannot be deleted from past dates
- **Visual indicators**: Past dates show "Read Only" badge and muted text colors

## PDF Export

The app allows you to export your tasks as beautifully formatted PDF documents:

- **Date Range Selection**: Choose any start and end date for export
- **Professional Layout**: Clean, organized PDF with proper formatting
- **Task Details**: Includes completion status and task descriptions
- **Progress Tracking**: Shows completion statistics for each date
- **Printable**: Optimized for both digital viewing and printing

### Export Process:
1. Go to the "All Lists" screen
2. Tap the menu button (⋮) in the top-right corner
3. Select "Export to PDF"
4. Choose your desired date range
5. The PDF will be generated and ready to print or share

## Design Highlights

- **Material 3**: Latest Material Design with dynamic color theming
- **Smooth Animations**: Page transitions and micro-interactions
- **Modern Typography**: Clean, readable font hierarchy
- **Thoughtful Spacing**: Proper padding and margins for comfort
- **Visual Feedback**: Hover states, focus indicators, and loading states
- **Accessibility**: Proper semantic labels and touch targets

## Database Schema

### Todo Lists Table
- `id`: Primary key
- `date`: Unique date string (YYYY-MM-DD format)
- `created_at`: Timestamp when the list was created

### Todo Items Table
- `id`: Primary key
- `list_id`: Foreign key referencing todo_lists
- `title`: Task description
- `is_completed`: Boolean (0/1) indicating completion status
- `created_at`: Timestamp when the item was created

## Development

To run tests:
```bash
flutter test
```

To build for release:
```bash
flutter build apk    # Android
flutter build ios    # iOS
flutter build web    # Web
```
