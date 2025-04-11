# Heywork App Documentation

figma 
https://www.figma.com/proto/AYcPMPzmRRoT6mHoGc2pMT

## Project Overview

Heywork is a hiring platform that connects business owners with part-time and full-time workers in a simple and efficient manner. The platform serves two primary user groups:

1. **Hirers** - Business owners who need workers for part-time or full-time jobs
2. **Workers** - Individuals looking for part-time work or permanent job opportunities

The application is built using Flutter with Firebase as the current backend solution, designed with a clean architecture that allows for potential migration to other backend services in the future.

## Architecture Overview

Heywork follows Clean Architecture principles with a modular, feature-based structure. The architecture is divided into several layers:



feat(auth): add phone authentication with Firebase

fix(band-profile): correct image upload bug on profile page

docs(readme): update installation steps

style(home): apply consistent spacing and font size

refactor(event): split event creation logic into separate service

perf(app): lazy load feed images for better scroll performance

test(auth): add unit tests for OTP verification

chore: update Flutter version and fix lints

```
/lib
  /core        - Core utilities, services, and widgets
  /data        - Data models, repositories, and data sources
  /domain      - Business entities, repository interfaces, and use cases
  /presentation - BLoCs, events, and states
  /features    - Feature-specific screens and widgets
  /config      - Configuration files
  main.dart    - Application entry point
```

### Core Principles

1. **Separation of Concerns** - Each layer has a specific responsibility
2. **Dependency Inversion** - High-level modules don't depend on low-level modules
3. **Abstraction** - Firebase and other external services are abstracted behind interfaces
4. **Testability** - Business logic is separated from UI to facilitate testing
5. **Feature Modularity** - Features are self-contained and can be developed independently

## Layer Descriptions

### Core Layer

The Core layer contains shared utilities, services, and widgets used throughout the application.

- **Services**: Interfaces and implementations for authentication, database, and storage
- **Widgets**: Reusable UI components
- **Utils**: Helper functions and constants
- **Theme**: Application styling and theming
- **Routes**: Navigation configuration
- **DI**: Dependency injection setup

### Data Layer

The Data layer handles data operations and external data sources.

- **Models**: Data transfer objects for API communication
- **Repositories**: Implementations of domain repository interfaces
- **Data Sources**: Local and remote data sources (Firebase implementations)

### Domain Layer

The Domain layer contains business logic and rules.

- **Entities**: Business objects representing core concepts
- **Repositories**: Interfaces defining data operations
- **Use Cases**: Specific business logic operations

### Presentation Layer

The Presentation layer manages UI state using the BLoC pattern.

- **BLoCs**: Business Logic Components
- **Events**: Input events for BLoCs
- **States**: Output states for UI rendering

### Features Layer

The Features layer contains feature-specific screens and widgets.

- **Authentication**: Login, signup, and user type selection
- **Onboarding**: Onboarding flows for new users
- **Hirer**: Hirer-specific screens and workflows
- **Worker**: Worker-specific screens and workflows
- **Verification**: Code verification for job start
- **Payments**: Payment processing screens
- **Ratings**: Rating submission and display

## Backend Abstraction

The application uses Firebase for authentication, database, and storage but is designed to allow for future migration to other backend services. This is achieved through:

1. **Service Interfaces**: All Firebase services implement interfaces that define expected behavior
2. **Repository Pattern**: Repositories abstract data operations behind interfaces
3. **Data Sources**: Firebase-specific code is isolated in data source implementations
4. **Dependency Injection**: Services are injected where needed, allowing for easy replacement

## State Management

The application uses the BLoC (Business Logic Component) pattern for state management:

- **Events**: Input events triggered by user actions
- **States**: Output states consumed by the UI
- **BLoCs**: Components that transform events into states based on business logic

## Key Features

### For Hirers

1. **Part-Time Hiring**
   - Choose services
   - Select available workers
   - Pay service charges
   - Verify worker arrival using unique codes

2. **Permanent Hiring**
   - Post job openings
   - Access worker applications
   - Review worker profiles and ratings

### For Workers

1. **Profile Management**
   - Create and update profiles
   - Select available services
   - Build reputation through ratings

2. **Job Management**
   - Receive job requests
   - Accept or decline job offers
   - Verify job start using codes
   - Complete shifts and get paid

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Firebase project setup

### Installation

1. Clone the repository
   ```
   git clone https://github.com/your-username/heywork.git
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Configure Firebase
   - Create a Firebase project in the Firebase console
   - Add Android and iOS applications to your Firebase project
   - Download and add the configuration files to your project
   - Enable Authentication, Firestore, and Storage in the Firebase console

4. Run the application
   ```
   flutter run
   ```

## Development Guidelines

### Coding Standards

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Use meaningful variable and function names
- Write comments for complex logic
- Create separate files for classes
- Keep functions and methods small and focused

### File Naming Conventions

- Use snake_case for file names
- Use lowercase letters for directory names
- Append _screen.dart to screen files
- Append _widget.dart to widget files
- Append _bloc.dart, _event.dart, and _state.dart to BLoC files

### Testing

- Write unit tests for all use cases
- Write unit tests for repositories and data sources
- Write widget tests for UI components
- Use mock objects for dependencies in tests

## Migration Strategy

The application is designed to support migration from Firebase to other backend services:

1. **Create New Service Implementations**: Implement service interfaces for the new backend
2. **Update Data Sources**: Create new data source implementations for the new backend
3. **Update Dependency Injection**: Update the DI container to use the new implementations
4. **Test Thoroughly**: Ensure all features work correctly with the new backend
5. **Deploy**: Release the updated application with the new backend

## Performance Considerations

- Minimize rebuild of widgets using `const` constructors
- Use pagination for large lists
- Implement caching for frequently accessed data
- Optimize image loading and processing
- Use lazy loading for non-critical data

## Security Considerations

- Implement proper authentication and authorization
- Validate all user inputs
- Use secure storage for sensitive data
- Implement proper error handling
- Follow Firebase security best practices

## Contributing

1. Fork the repository
2. Create a new branch for your feature
3. Write tests for your feature
4. Implement your feature
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any questions or concerns, please contact:
- Email: support@heywork.com
- Website: https://www.heywork.com