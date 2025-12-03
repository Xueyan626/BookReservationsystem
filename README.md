# Library Reservation Platform – Group 5

### 1. Project Overview  

This project aims to provide libraries with a unified online platform to facilitate book reservations, waiting list management, and community book review interactions for users. Traditional libraries face issues such as scattered information and low efficiency in managing reservations and communicating with readers. This project will address these issues by centralizing processes through a web application, thereby enhancing user experience and book utilization rates.



### 2. Key Features  

**(1) Authentication and Account Management**

Dual-email registration (password stored as hash), reader-side OTP + password login, administrator single-step password login, with profile/password updates via UserProfileController.

**(2) Reader Discovery and Interaction**

Homepage displays popular booklists, supports keyword and author search, category browsing, and features an integrated ChatGptDialog.vue chat assistant for catalog-based intelligent recommendations.

**(3) Book Details, Reviews, and Favorites**

Detailed pages showing inventory status, reservation counts, and favorite toggle via /api/favorites. User reviews managed through CommentController. Dedicated favorites panel for bulk add/delete/cleanup.

**(4) Reservation Management**

End-to-end queue management covering subscription, cancellation, pickup, return, and automatic reassignment to next reader.

**(5) Admin Console**

Vue-based library CRUD suite supporting cover selection, book management, tag management, reservation approval/return processing, review moderation, and user governance via /api/admin/* interfaces (search, password reset, ban/unban). 



### 3. Overall Objectives  

(1) Improve library resource utilization and management efficiency.  

(2) Enhance reader engagement and community interaction.  

(3) Achieve an integrated platform for reservation, waiting list, and review functions.  



### 4. Team Roles and Responsibilities  

| Role                         | Name                           | Job Description                                              |
| ---------------------------- | ------------------------------ | ------------------------------------------------------------ |
| **Project Manager**          | Hanyu Liu                      | Responsible for overall project planning and progress control, coordinating team members' work, managing requirements changes and risks. |
| **UI/UX Designer**           | Xueyan Yang, Shengqi Zhou      | Responsible for interface visual design and user experience optimization, drawing wireframes and prototypes, and conducting usability testing. |
| **Frontend Developer**       | Shengqi Zhou, Xueyan Yang      | Responsible for user interface design and implementation, ensuring a user-friendly interaction experience, and integrating with backend APIs. |
| **Backend Developer**        | Xin Wang, Zheng Liu, Hanyu Liu | Responsible for server-side system development, including API design, database modeling, business logic implementation, performance optimization, and security assurance. |
| **Database Developer**       | Xin Wang                       | Establish a data dictionary, create and update databases, and design SQL statements for operating databases. |
| **QA Engineer**              | Zheng Liu                      | Develops test plans and test cases, executes functional, performance, and security tests, and ensures system quality and stability. |
| **Documentation \& Support** | Zheng Liu                      | Writes user manuals, maintains development documentation, collects user feedback, and provides technical support. |

### 5. Running the Application
(1) Prerequisites: Install Node.js 18+, Java 21 (or compatible JDK), Maven (or use bundled wrapper), MySQL 8.x, and obtain a Gmail app password for SMTP; an optional OpenAI API key is required for real-time chat completion.

(2) Prepare the database: Start MySQL, create a schema named `library_reservation_system`, and import `library-reservation-system/library_reservation_system.sql`. If your MySQL username/password differs, update `library-reservation-system/src/main/resources/application.properties` while maintaining the `spring.jpa.hibernate.ddl-auto=validate` configuration to ensure the schema exists before startup.

(3) Compile and run the library-reservation-system program to start the project's backend.

(4) Navigate to the my-vue-app directory within the project directory. In the terminal, run “npm install” followed by “npm run dev”. Then visit http://localhost:5173.

### 6. All used Libraries and Their Versions
#### Backend (Java)
- Spring Boot: 3.5.5
- Spring Boot Starter Web: 3.5.5
- Spring Boot Starter Data JPA: 3.5.5
- Spring Boot Starter Validation: 3.5.5
- Spring Boot Starter Mail: 3.5.5
- Spring Boot Starter Test: 3.5.5
- Spring Security Crypto: 6.x (managed by Spring Boot)
- MySQL Connector/J: 9.x (managed by Spring Boot)
- JJWT (Java JWT): 0.12.5
- Lombok: 1.18.x (managed by Spring Boot)
- Maven Compiler Plugin: 3.14.0
- Maven Surefire Plugin: 3.2.5
- JaCoCo Maven Plugin: 0.8.12

#### Frontend (Vue.js)
- Vue: 3.5.22
- Vue Router: 4.5.1
- Tailwind CSS: 3.4.18
- Tailwind Forms Plugin: 0.5.10
- PostCSS: 8.5.6
- Autoprefixer: 10.4.21
- Vite: 7.1.7
- Vite Vue Plugin: 6.0.1

#### Database and Runtime
- MySQL Server: 8.x
- Java JDK: 21
- Node.js: 18+
