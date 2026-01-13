# 📘 User documentation

This document provides a clear guide on how to operate, manage, and monitor the **Inception** infrastructure. It is designed for system administrators and end-users.

---

### 💡 Services provided by the stack

The architecture is built on **Alpine Linux** for minimal resource usage and consists of the following services:

* **NGINX:** Acts as the secure entry point to the infrastructure, configured with TLSv1.2/1.3 to handle HTTPS requests to the internal services.

* **WordPress + PHP-FPM:** Runs the Wordpress Content Management System via PHP-FPM. Handles the dynamic web content and communicates with the database.

* **MariaDB:** A persistent database for WordPress. It uses a custom entrypoint script and handles credentials via **Docker Secrets**.

**Bonus Part:**

* **Redis:** Acts as a high-performance object cache for WordPress, reducing database load and improving response times.

* **FTP Server:** Provides secure direct access to the WordPress filesystem, facilitating file management and uploads.

* **Static Website:** A dedicated container serving a custom HTML/CSS website. Demonstrates hosting a lightweight static page alongside the dynamic Wordpress service.

* **Adminer:** A lightweight database management interface used to manage the MariaDB database via a web GUI.

* **GoAccess:** A real-time web log analyzer that visualizes NGINX server metrics and traffic statistics.

---

### 🚀 Start and stop the project.

The entire infrastructure is orchestrated via Docker Compose and managed using a `Makefile` for simplicity.

#### Start the project

**1. Setup environment and secrets**
    - Your `.env` file needs to be in the `srcs` directory
    - Your `secrets` are in the secrets directory

**2. Build and Run**

Run `make` to build the images and run the containers in the background.

Check that the containers are running using `make ps` and view logs using `make logs`

#### Stop the project

To stop the containers
```bash
make down
```
To remove the persistent data volumes

```bash
make clean
```

---

### 🌐 Access the website and the administration panel.

Once the project is running, you can access the services via your web browser.

🔹 Network Configuration

The project is configured to run on the domain `ielmoudd.42.fr`. You must map this domain to your local machine (localhost) for the routing and SSL certificates to function correctly.

1.  Open your hosts file:
    ```bash
    sudo nano /etc/hosts
    ```
2.  Add the following line:
    ```
    127.0.0.1   ielmoudd.42.fr
    ```

**WordPress Website**

`https://ielmoudd.42.fr`

**WordPress Admin**

`https://ielmoudd.42.fr/wp-admin`

**Static Website**

`https://ielmoudd.42.fr:600`

**Adminer**

`https://ielmoudd.42.fr:500`

**GoAccess**

`https://ielmoudd.42.fr:700`

---

### 🔑 Locate and manage credentials.

**Where are credentials stored?**

**1. On the Host**

* **Environment Variables**: Located in the `.env` file inside the srcs/ directory.

* **Secrets**: Sensitive keys are stored in the `secrets/` directory.

**2. Inside the Container**

* **Environment Variables**: Loaded into the system environment (viewable via env command).

* **Secrets**: Mounted as read-only files in /run/secrets/.


**Using .gitignore**

We use a `.gitignore` file to tell Git to strictly ignore our sensitive files. This ensures that our actual passwords and keys never leave the local machine.

* **.gitignore configuration:**

```bash
srcs/.env
secrets/
```

---

### ⚡ Check that the services are running correctly

🔸 **Check Service Status**

```bash
make ps
```

🔸 **View Live Logs**

```bash
make logs
```

🔸 **Verify Redis Cache Connection**

To ensure the caching system is active:

- Log in to the **WordPress Admin Dashboard**.

- Navigate to **Settings > Redis**.

- The status indicator should be green and say **"Connected"**.


🔸 **Verify FTP Connection**

1.  **Connect to the server:**

```bash
ftp ielmoudd.42.fr
```

2.  **Authenticate:**
    * **Name:** Enter the `FTP_USER` defined in your `.env`.
    * **Password:** Enter the `FTP_PASSWD` defined in your `secrets`.

3.  **Test:**

Run the list command to see the WordPress files:
```bash
ls
```
