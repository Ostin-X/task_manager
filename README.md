# Task Manager

Welcome to the Task Manager app! This application helps you manage tasks and projects efficiently with a clean and intuitive interface.

## Getting Started

There are two ways to start using the Task Manager:

### 1. Try the Live Deployed Version

Explore the app in action without setup:

- Go to [https://task-manager-ostin.fly.dev/](https://task-manager-ostin.fly.dev/)

### 2. Run the Project Locally

1. Clone the project:
    ```bash
    git clone -b dev https://github.com/Ostin-X/task_manager.git
    ```
2. Go to the project directory:
    ```bash
    cd task_manager
    ```
   
### Option 2a: Using Docker Compose (~~Recommended~~) Buggy

1. Start the application:
   ```bash
   docker-compose -p peshekhonov -f ./docker/docker-compose.yml up --build -d
   ```
2. Populate the database with sample data:
    - Visit [http://localhost:4000/populate](http://localhost:4000/populate) and press the button to seed the database.

### Option 2b: Manual Setup

1. Start the database on port `5433`:
   ```bash
   docker-compose up -d
   ```

2. Get deps and setup the application with db setup:
    ```bash
    mix setup
   ```

   - If Moon shows a slots error, just run mix setup again.


3. Start the server:
   ```bash
   mix phx.server
   ```

### Default Logins

To access the app, use one of the following accounts:

- **Email:** `admin@admin.com` **Password:** `admin`
- **Email:** `admin2@admin.com` **Password:** `admin`
- **Email:** `admin3@admin.com` **Password:** `admin`

All default accounts share the same password set in your seed configuration.

---

Enjoy using the Task Manager app!
