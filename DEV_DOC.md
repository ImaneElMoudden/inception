# 🛠️ Developer Documentation

This document outlines the technical steps required to set up the **Inception** development environment from scratch. It details the prerequisites, configuration files, and secret management required to build the stack.

---

## Set up the environment from scratch (prerequisites, configuration files, secrets).

### 1. 📋 Prerequisites

Before initializing the project, ensure your development machine meets the following requirements:

#### 🔹 Software Requirements
* **Operating System:** Linux (Virtual Machine or Native)
* **Docker Engine:** v20.10+
* **Docker Compose:** v2.0+
* **Make:** For build automation


### 2. 📂 Project Structure

Understanding the folder hierarchy is essential for development:

* **📂 srcs/**
    * **📄 docker-compose.yml:** The orchestrator file defining services, networks, and volumes.
    * **📄 .env:** Contains all environment variables and secrets.
    * **📂 requirements/**: Contains the build context for each service (Dockerfiles, config files, scripts).
        * `mariadb/`
        * `wordpress/`
        * `nginx/`
        * ...
* **📂 secrets/**: Stores SSL certificates and sensitive keys.
* **📄 Makefile:** Automates the build, setup, and teardown processes.
* **📄 gitignore:** hide credentials


### 3. Host Configuration (`/etc/hosts`)
The infrastructure relies on local domain resolution. The project URL must be mapped to the local loopback address:

1.  Open your hosts file:
    ```bash
    sudo nano /etc/hosts
    ```
2.  Add the following line:
    ```
    127.0.0.1   login.42.fr
    ```


### 4. 🔐 Docker Secrets & Configuration Management

**Environment Variables (`.env`):** Used for non-sensitive configuration (domain names, user names).

**Docker Secrets:** Sensitive data (passwords, keys) must not be hardcoded in the docker-compose.yml or Dockerfiles.

* Implementation: Secrets should be passed as files mounted to /run/secrets/ inside the container or injected via environment variables only at runtime from the .env file (depending on the specific evaluation requirement).


---

## 🚀 Build and launch the project using the Makefile and Docker Compose.

The build process must be automated using a Makefile that wraps Docker Compose commands.

🔹 **Makefile Requirements**
The Makefile must be located at the root of the repository and include the following rules:

all: Builds images and starts the stack.

clean: Stops containers and removes images.

fclean: Deep clean that also removes persistent data volumes.

re: Rebuilds the environment from scratch.

🔹 **Docker Compose and Dockerfiles**
**Building from Scratch:** The `docker-compose.yml` must use the build: context for every service.

**Base Image:** All Dockerfiles must inherit from Alpine / Debian Linux (penultimate stable version).

**Entrypoints:** Custom shell scripts (`entrypoint.sh`) must be used to handle service initialization (e.g., configuring WordPress) before the main process starts.

---

## 🛠️ Use relevant commands to manage the containers and volumes.

### 🔹 Build and Start

Builds the images from scratch and starts the containers in the background.
    ```bash
    docker compose -f srcs/docker-compose.yml up -d --build
    ```

### 🔹 Stop and Remove

Stops all running containers and removes the created networks (volumes are preserved).
    ```bash
    docker compose -f srcs/docker-compose.yml down
    ```

### 🔹 Stop and Remove Volumes

Stops containers and removes **both** networks and persistent volumes (database data will be lost).
    ```bash
    docker compose -f srcs/docker-compose.yml down -v
    ```

### 🔹 Check Status

Shows the current state (Up/Exit), ports, and names of the containers.
    ```bash
    docker compose -f srcs/docker-compose.yml ps
    ```

### 🔹 View Logs

Streams the logs from all services. Useful for catching startup errors or application bugs.
    ```bash
    docker compose -f srcs/docker-compose.yml logs -f
    ```

### 🔹 List Volumes

Shows all active Docker volumes where data is persisted.
    ```bash
    docker volume ls
    ```

### 🔹 Inspect a Volume

Displays detailed information about a specific volume (e.g., mount point).
    ```bash
    docker volume inspect <volume_name>
    ```

### 🔹 Clean Unused Resources

Removes stopped containers, unused networks, and dangling images to free up space.
    ```bash
    docker system prune -a
    ```

### 🔹 Network Management

The project requires a custom Docker Network to bridge containers.

Use `docker network inspect <network_name>` to verify that containers are assigned the correct internal IPs and that service discovery (DNS) is functioning.


---

## 💾 Identify where the project data is stored and how it persists.

**Data persistence** is a critical requirement. The infrastructure distinguishes between ephemeral container data and persistent application data.

🔹 **Storage Strategy**
**Docker Volumes:** Used to store persisting data and is managed entirely by Docker to ensure that critical information survives even if the container is deleted.

🔹 **Persistence Location**
Persistent data must be stored on the host machine in a specific location (`/home/login/data`).

🔹 **Verification of Persistence**

To verify persistence works as intended:

* Add data to the application (e.g., create a WordPress post).

* Remove the containers (docker compose down).

* Restart the containers (docker compose up).

* The data should still be present.

* Executing make fclean will reset the environment completely.
