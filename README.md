# PocketPay

PocketPay is a personal expense tracker built with Flutter. It helps you record income and expenses, understand spending patterns, and keep financial data available offline.

## Features

- Track income and expense transactions by category
- Store data locally with Hive
- View a dashboard with current balance and recent activity
- Review transaction history
- Explore spending analytics with charts
- Export transaction data to CSV
- Switch between light and dark themes

## Tech stack

- [Flutter](https://flutter.dev/) for the user interface
- [Riverpod](https://riverpod.dev/) for state management
- [Hive](https://docs.hivedb.dev/) for local persistence
- [GoRouter](https://pub.dev/packages/go_router) for navigation
- [fl_chart](https://pub.dev/packages/fl_chart) for analytics charts

## Getting started

### Prerequisites

- Flutter SDK (Dart SDK 3.0 or later)

### Run locally

```bash
git clone https://github.com/Joshua-5566/PayPocket.git
cd PayPocket
flutter pub get
flutter run
```

### Run tests

```bash
flutter test
```

## Project structure

```text
lib/
├── core/             # Shared theme, utilities, widgets, and Hive adapters
├── features/         # Dashboard, transactions, analytics, and settings
├── routes/           # GoRouter configuration
└── services/         # Local data and export services
```

## License

This project is available under the [MIT License](LICENSE).
