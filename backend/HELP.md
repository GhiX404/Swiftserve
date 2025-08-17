en# Snuggy Backend

This is the Spring Boot backend for the Snuggy Canteen Food Ordering System. It provides REST APIs, WebSocket support, and integrations with Firebase, Redis, and PostgreSQL. Below is a guide on where to place files within the project structure to maintain organization and consistency.

## Project Structure

```
backend/
├── .idea/                  # IntelliJ configuration (auto-generated, do not edit manually)
├── .mvn/                   # Maven wrapper (auto-generated, do not edit manually)
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── snuggy/
│   │   │           └── backend/
│   │   │               ├── BackendApplication.java  # Main application class
│   │   │               ├── config/                 # Configuration classes (e.g., FirebaseConfig.java, RedisConfig.java)
│   │   │               ├── controller/             # REST controllers (e.g., OrderController.java, RfidController.java)
│   │   │               ├── entity/                 # JPA entities (e.g., User.java, Order.java)
│   │   │               ├── repository/             # JPA repositories (e.g., UserRepository.java, OrderRepository.java)
│   │   │               ├── service/                # Business logic (e.g., OrderService.java, RedisService.java)
│   │   │               ├── security/               # Security configurations (e.g., JwtUtil.java, SecurityConfig.java)
│   │   │               └── util/                   # Utility classes (e.g., NdefParser.java)
│   │   ├── resources/
│   │   │   ├── application.yml                    # Application configuration (DB, Redis, CORS, Firebase)
│   │   │   ├── service-account.json               # Firebase service account (add to .gitignore)
│   │   │   └── static/                            # Static assets (e.g., images, if needed)
│   │   └── test/                                  # Test classes (e.g., OrderControllerTest.java)
├── Dockerfile                                      # Docker configuration for building the app
├── pom.xml                                         # Maven build file with dependencies
└── README.md                                       # This file
```

## File Placement Guide

- `BackendApplication.java`: Main entry point of the Spring Boot application. Keep in the root `com.snuggy.backend` package.
- `config/`: Place configuration classes here, such as:
  - `FirebaseConfig.java` (FCM setup)
  - `RedisConfig.java` (Redis connection)
  - `WebSocketConfig.java` (WebSocket configuration)
- `controller/`: Add REST controller classes, e.g.:
  - `OrderController.java` (APIs like `/orders/rfid/scan`)
  - `RfidController.java` (APIs for RFID interactions)
- `entity/`: Define JPA entities matching the schema, e.g.:
  - `User.java` (users table)
  - `Order.java` (orders table)
  - `Balance.java` (balances table)
- `repository/`: Create JPA repository interfaces, e.g.:
  - `UserRepository.java` (CRUD for users)
  - `OrderRepository.java` (CRUD for orders)
- `service/`: Implement business logic, e.g.:
  - `OrderService.java` (order retrieval logic)
  - `RedisService.java` (scan_id storage)
  - `NotificationService.java` (FCM notifications)
- `security/`: Add security-related classes, e.g.:
  - `JwtUtil.java` (JWT token handling)
  - `SecurityConfig.java` (Spring Security configuration)
- `util/`: Place utility classes, e.g.:
  - `NdefParser.java` (NFC payload parsing)
- `resources/application.yml`: Configure database, Redis, CORS, and Firebase settings.
- `resources/service-account.json`: Store Firebase credentials (secure and ignore in Git).
- `resources/static/`: Optional; use for static files if needed later.
- `Dockerfile`: Define the Docker image build instructions.
- `pom.xml`: Manage dependencies (e.g., Spring Web, JPA, Redis, Firebase).
- `README.md`: Update this file with project-specific notes or changes as the project evolves.

## Setup Instructions
1. Install PostgreSQL and ensure `psql` is in your PATH.
2. Run: `psql -U postgres -f setup.sql` to create `canteen_db`.
3. Update `application.yml` with your PostgreSQL credentials.
4. Run `mvn clean install` to build the project.
5. Start the app with `mvn spring-boot:run` or via Docker.

## Notes

- Ensure all new classes follow the `com.snuggy.backend` package structure.
- Add test files under `src/test/java/com/snuggy/backend/` as needed.
- Update this README with additional setup steps or file details as the project evolves.

Happy coding! 🚀
```

