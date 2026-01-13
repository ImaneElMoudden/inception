_This project has been created as part of the 42 curriculum by ielmoudd._

# Inception

## 📚 Table of contents:

- [Project Description](#project-description)
- [Project Architecture & technical choices](#project-architecture--technical-choices)
- [Concepts Comparison](#concepts-comparison)
- [Deep Dive into Concepts](#deep-dive-into-concepts)
- [Instructions](#instructions)
- [Resources](#resources)

---

## 📝 Project Description

#### 🔹 Goal

This project serves as a system administration practical exercise, using Docker to build a containerized infrastructure. The objective is to understand the core concepts of **Docker** by building custom images from scratch, managing service isolation and configuring a secure internal network.

#### 🔹 Overview

This project involves setting up a small infrastructure composed of different services operating in separate containers, managed via **Docker Compose**.

The architecture is built on **Alpine Linux** for minimal resource usage and consists of the following services:

* **NGINX:** Acts as the secure entry point to the infrastructure, configured with TLSv1.2/1.3 to handle HTTPS requests to the internal services.

* **WordPress + PHP-FPM:** Runs the Wordpress Content Management System via PHP-FPM. Handles the dynamic web content and communicates with the database.

* **MariaDB:** A persistent database for WordPress. It uses a custom entrypoint script and handles credentials via **Docker Secrets**.

**Bonus Part:**

* **Adminer:** A lightweight database management interface used to manage the MariaDB database via a web GUI.

* **FTP Server:** Provides secure direct access to the WordPress filesystem, facilitating file management and uploads.

* **Redis:** Acts as a high-performance object cache for WordPress, reducing database load and improving response times.

* **GoAccess:** A real-time web log analyzer that visualizes NGINX server metrics and traffic statistics.

* **Static Website:** A dedicated container serving a custom HTML/CSS website. Demonstrates hosting a lightweight static page alongside the dynamic Wordpress service.

All these containers communicate over a dedicated internal **Docker network** to ensure security.

Data persistence for the database and website files is handled through **Docker volumes**.

---

## 🛠️ Project Architecture & Technical Choices

#### 🔻 Technologies Used
* **Containerization:** Docker, Docker Compose
* **Operating System:** Alpine Linux (Penultimate Stable Version)
* **Web Server:** NGINX (TLSv1.2/1.3)
* **Application:** WordPress, PHP-FPM
* **Database:** MariaDB
* **Security:** OpenSSL (Self-signed certificates)

#### 🔻 Main Design Choices

* **Alpine as Base OS:** It is an extremely lightweight distribution, which reduces the final image size, and accelerates building and deployment.

* **Building the images from scratch:** This provides control over which packages and dependencies are installed in the final image and demonstrates a deep understanding of the service configuration.

* **One service per container:** Each service runs in its own isolated container. This simplifies debugging by isolating logs and errors and keeps other services running when a service crashes.
<!-- using scripts as entrypoint -->

* **NGINX as an entry point:** 
NGINX is used as the main entry point for the website. It handles the secure connection (HTTPS) and passes requests to WordPress. This keeps the WordPress and MariaDB containers hidden from direct external access.

* **Docker network for internal communication:**
Established a dedicated internal network for the containers. This allows them to communicate securely using service hostnames (like `wordpress:9000`) instead of relying on unstable IP addresses, effectively isolating their traffic from the host machine.

* **Docker Volumes for Data Persistence:**
Using Docker Volumes to save critical data ensures that WordPress website files and the MariaDB database content remain intact when the containers are restarted or deleted.

* **Security with Docker Secrets:**
Sensitive information (such as database passwords) is not hardcoded in environment variables. Using Docker Secrets is a safe way to mounts credentials securely into the containers only at runtime.


#### 🔻 Use of Docker & Sources included

##### How Docker is Used
This project utilizes Docker to create a portable and modular infrastructure. Rather than installing services directly on the host machine, we define the environment for each service (NGINX, WordPress, MariaDB) within its own container.

* **Dockerfiles:** Each service has a dedicated `Dockerfile` that starts from the penultimate stable version of Alpine Linux. These files contain the instructions to install the specific packages and dependencies needed for that service.

* **Docker Compose:** We use `docker-compose.yml` to orchestrate these individual containers, defining their networks, volumes, and startup order in a single declarative file.

##### Sources Included
Per the project requirements, we do not use pre-built images with the services already installed (e.g., we do not use `image: wordpress`). Instead, all sources are included in the repository to build the infrastructure from scratch:

* **Configuration Files:** Custom configuration files for NGINX (`nginx.conf`) and ftp server are stored locally and copied into the containers during the build process.

* **Shell Scripts:** We include custom shell entrypoint scripts to handle runtime tasks like initializing the database or configuring WordPress for the first launch.

* **Web Content:** The static website source code (HTML/CSS) is included directly in the source folder.

---

## 💡Concepts Comparison

#### 🔸 Virtual Machines vs Docker
* **Virtual Machines (VM):**
    * **Isolation:** Uses hardware-level virtualization. Each VM runs a full operating system, completely isolated from the host.
    * **Performance:** Heavy resource usage (RAM/CPU) and slow boot times.
    * **Portability:** Large snapshot files that are difficult to move.

* **Docker (Containers):**
    * **Isolation:** Uses OS-level virtualization. Containers share the host's kernel but keep processes separate.
    * **Performance:** Extremely lightweight with near instant startup times.
    * **Portability:** Lightweight images (MBs) that run consistently on any system with Docker installed.


#### 🔸 Secrets vs Environment Variables

* **Environment Variables:**
    * **Behavior:** Variables are passed directly to the container's environment.
    * **Security Risk:** They are visible if anyone runs `docker inspect` or `printenv`.
    * **Use Case:** Best for non-sensitive configuration

* **Docker Secrets:**
    * **Behavior:** Data is encrypted at rest and mounted as a file (e.g., in `/run/secrets/`) only when the container is running.
    * **Security Benefit:** They are never exposed in the environment variables or command history.
    * **Use Case:** Mandatory for sensitive data, like database passwords.

#### 🔸 Docker Network vs Host Network

* **Docker Network:**
    * **Description:** Creates an isolated internal network for the containers.
    * **Behavior:** Containers communicate securely using service hostnames (e.g., `mariadb`) and ports are closed to the outside world unless explicitly mapped.

* **Host Network:**
    * **Description:** Removes network isolation completely.
    * **Behavior:** The container shares the host machine's IP address and network namespace. This is faster but can cause port conflicts (can't run two services on the same port).

#### 🔸 Docker Volumes vs Bind Mounts

* **Docker Volumes:**
    * **Storage Location:** Docker and stored in a protected area of the host filesystem, e.g., `/var/lib/docker/volumes/`.
    * **Best For:** Persisting critical data (like database storage) that should survive container deletion. They are safer and easier to back up.

* **Bind Mounts:**
    * **Storage Location:** The User maps a specific file or folder path from the host to the container.
    * **Best For:** Used to inject custom configuration files or live code development. The applied changes on the host to immediately appear in the container.

---

## ⚙️ Instructions

#### ♦ Prerequisites

* Docker Engine
* Docker Compose

#### ♦ Installation

1. Clone the repository

2. Setup environment and secrets
    - Your `.env` file needs to be in the `srcs` directory
    - Your `secrets` are in the secrets directory

3. Build and Run

Run `make` to build the images and run the containers in the background.

4. Check status and logs

Check that the containers are running using `make ps` and view logs using `make logs`

5. Access the application

Once the containers are running, open your browser and navigate to:

* **WordPress Website:** `https://ielmoudd.42.fr`
* **Adminer (Database GUI):** `https://ielmoudd.42.fr:500`
* **Static Website:** `https://ielmoudd.42.fr:600`
* **GoAccess service:** `https://ielmoudd.42.fr:700`

#### ♦ Makefile commands:

| Command | Description |
| :--- | :--- |
| `make` / `make up` | Generates SSL certificates (if missing), builds the images, and starts the containers in detached mode. |
| `make down` | Stops the containers and removes the internal Docker network. |
| `make clean` | Stops containers, removes Docker volumes, and prunes unused images/networks. |
| `make re` | make clean and make all. |
| `make logs` | Displays logs from all running containers. |
| `make ps` | Lists the current status of the containers. |

---

## 📑 Resources

* **Docker:** 
    - [Docker Engine Docs](https://docs.docker.com/engine/)
    - [Docker Compose Docs](https://docs.docker.com/compose/)

* **MariaDB:**
    - [Setup Mariadb on alpine](https://wiki.alpinelinux.org/wiki/MariaDB)

* **Alpine:**
    - [Alpine docker image](https://hub.docker.com/_/alpine)

* **Nginx:**
    - [Setup Nginx on alpine](https://wiki.alpinelinux.org/wiki/Nginx)
    - [Configure Nginx with PHP](https://wiki.alpinelinux.org/wiki/Nginx_with_PHP)
    - [Nginx beginner's guide](https://nginx.org/en/docs/beginners_guide.html)

* **WordPress:**
    - [Setup wordpress on Alpine](https://wiki.alpinelinux.org/wiki/WordPress)


**AI Usage:**
    - Used AI to simplify new topics such as docker engine architecture, and the differences between bind mounts and docker volumes
    - Interpret the NGINX config file syntax
    - Further research and identify best practices for system administration and containerization, specifically regarding security and isolation.
