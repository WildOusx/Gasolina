# Gasoline Calendar App

## Overview
The Gasoline Calendar App is a web application designed to help users track gasoline distribution schedules based on vehicle plate numbers. The application provides an easy-to-use interface for users to input their plate numbers and view the corresponding gasoline schedule.

## Features
- Displays gasoline distribution schedule based on vehicle plate endings.
- User-friendly interface for inputting plate numbers.
- Interactive calendar view to visualize gasoline distribution days.

## Project Structure
```
gasoline-calendar-app
├── src
│   ├── app.ts                # Entry point of the application
│   ├── components
│   │   └── Calendar.tsx      # React component for displaying the gasoline schedule
│   ├── data
│   │   └── schedules.ts       # Contains gasoline distribution schedules
│   ├── utils
│   │   └── plateUtils.ts      # Utility functions for handling plate numbers
│   └── types
│       └── index.ts           # TypeScript interfaces for data structures
├── package.json               # npm configuration file
├── tsconfig.json              # TypeScript configuration file
└── README.md                  # Project documentation
```

## Installation
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd gasoline-calendar-app
   ```
3. Install the dependencies:
   ```
   npm install
   ```

## Usage
1. Start the application:
   ```
   npm start
   ```
2. Open your browser and go to `http://localhost:3000` to access the application.
3. Enter your vehicle plate number to view the gasoline distribution schedule.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License
This project is licensed under the MIT License.