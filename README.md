# SAPA (Screening Awal Perkembangan Anak)

SAPA is a mobile platform that enables teachers and parents to perform early screening of children’s development, providing quick assessments and visual summaries of growth indicators. SAPA is designed to help educators identify developmental milestones and potential concerns at an early stage. The application supports four types of users: Super Admin, School Admin/Principal, Teachers, and Parents/Students.

## ✨ Features

- 📊 STPPA (Standar Tingkat Pencapaian Pertumbuhan Anak)
- 🥧 Pie Chart Visualization
- 🖨️ Print Reports as PDF
- 👶 Student Management (manajemen Murid)
- 👩‍🏫 Teacher Management (manajemen Guru)
- 🏫 Admin Management (manajemen Admin)

## 🛠️ Tech Stack

- [Flutter](https://flutter.dev/) v3.32.8
- [Dart](https://dart.dev/) v3.8.1
- [Appwrite](https://appwrite.io/) (Backend as a Service)

## 🚀 Getting Started

Clone the repository:

```bash
git clone https://github.com/lukman-hakim-123/sapa.git
```

Install dependencies:

```bash
flutter pub get
```

Copy the example environment file and configure your credentials:

```bash
cp .env.example .env
```

Fill in your .env with your Appwrite project settings:

- APPWRITE_ENDPOINT
- APPWRITE_PROJECT_ID
- APPWRITE_DATABASE_ID

Generate required files:

```bash
dart run build_runner build
```

Run the app:

```bash
flutter run
```
