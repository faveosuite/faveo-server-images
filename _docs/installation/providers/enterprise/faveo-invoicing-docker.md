---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/faveo-invoicing-docker/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-09-17
last_modified_by: Sivakumar_C
toc: true
---
---
# <b>Deploying Faveo Invoicing (Community Edition) on Docker</b>   <!-- omit in toc -->
<img src="https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4e/Docker_%28container_engine%29_logo.svg/960px-Docker_%28container_engine%29_logo.svg.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=thumbnail" alt="drawing" width="300"/>

## <b>Faveo Invoicing on Docker</b>

A simplified Docker Compose workflow that sets up a network of containers for **Faveo Invoicing (Community Edition)**.

The setup script clones the source code directly from the official Faveo Invoicing Community Edition GitHub repository - no license or order number is required.

## <b>Usage</b>

---

To get started, make sure you have Docker and Docker Compose installed on your system, and then clone this repository with the command below.

```sh
git clone https://github.com/faveosuite/faveo-helpdesk-docker-v2.git
```

---
```sh
cd faveo-helpdesk-docker-v2/faveo-invoicing-docker
```
Next, navigate in your terminal to the directory you cloned this into, and give the setup script executable permissions.

```sh
chmod +x faveo-run.sh
```

---

### <b>Prerequisites to run the script:</b>

1. A valid domain name fully propagated to your server's IP.
2. Sudo privilege.
3. Unreserved ports 80 and 443. (If reserved, feel free to edit and change the ports of your choice in `docker-compose.yml`.)
4. SSL Certificate (for Paid SSL users) - if you're using a paid SSL, have the SSL certificate files ready before installation.
5. Operating Systems Ubuntu 22,24
6. Internet connectivity - the script clones the Faveo Invoicing Community Edition source from GitHub, and (for the Apache/Supervisor images) builds Docker images locally on first run.

---

Complete the below steps to get the containers up.

---

#### <b>Running the script</b>

Run the script <code><b>faveo-run.sh</b></code> by passing the necessary arguments. You can also run <code><b>./faveo-run.sh --help</b></code> at any time to print this usage information from the terminal.

**NOTE:** You should have a valid domain name pointing to your public IP. This domain name is used to obtain SSL certificates, and the email is used for the same purpose.

**SSL Certificate Options:** Pass the option based on your SSL requirement.

- Option A: Let's Encrypt (Free SSL)

- Option B: Self-Signed SSL

- Option C: Paid SSL

  In case of Paid SSL, please ensure your SSL files are ready on your system. If you choose Option C (Paid SSL), you must specify the paths of the SSL certificate files when prompted.

  SSL Certificate Path: */path/to/certificate.crt*

  SSL Key Path: */path/to/private.key*

  SSL CA Bundle: */path/to/ca_bundle.crt*

Usage:
```sh
./faveo-run.sh -domainname <your domainname> -email <example@email.com> -ssl <A|B|C>
```
Example: It should look something like this.
```sh
./faveo-run.sh -domainname yourdomianname.com -email yourgmail@gmail.com -ssl A
```
Help:
```sh
./faveo-run.sh --help
```

---

### <b>What the script does</b>

1. Checks prerequisites (Docker, Docker Compose, `unzip`, `curl`, `git`).
2. Obtains an SSL certificate based on the option chosen (Let's Encrypt, Self-Signed, or Paid).
3. Clones the [`faveo-invoicing-community`](https://github.com/faveosuite/faveo-invoicing-community) repository (`master` branch) into the `faveo` directory.
4. Generates a random database root password and application database credentials, and writes them into a `.env` file (based on `example.env`).
5. Creates the Docker network and volume used by the containers.
6. Builds the `faveo-apache` and `faveo-supervisor` images locally from the Dockerfiles under `Dockerfile/apache` and `Dockerfile/supervisor`, and brings up the containers (Apache, MySQL, Redis, Supervisor) via `docker-compose.yml`.
7. Saves the generated database credentials to `credentials.txt`.

---

After the Docker installation is completed, you will be prompted with database credentials. These credentials are saved in a file named `credentials.txt`. Make sure to store them somewhere safe.

A cronjob will be set to auto-renew SSL certificates from Let's Encrypt if you select SSL option A.

**Example credentials.txt:**
```
Faveo Invoicing Docker Setup Credentials
----------------------------------------
Faveo Docker installed successfully. Visit https://yourdomain.com from your browser.
Database Hostname: faveo-mysql
Mysql Database root password: BEJOwAfcCtHowJRs
Faveo Invoicing DB name: faveo
Faveo Invoicing DB User: faveo
Faveo Invoicing DB Password: /PV3/ubrtb4Jdk+N
```

---

Visit <code><b>https://yourdomainname.com</b></code> and complete the readiness probe. Now you can install Faveo Invoicing via the GUI installer wizard. Input the database details when prompted, and complete the installation.

There is one final step needed to complete the installation.

You have to edit the <code><b>.env</b></code> file which is generated under the Faveo root directory after completing the installation in the browser.

Open the terminal and navigate to the project directory. Here you will find the <code><b>faveo</b></code> directory, cloned when running the script, which contains the Faveo Invoicing codebase. Inside it, edit the <code><b>.env</b></code> file and add <code><b>REDIS_HOST=faveo-redis</b></code>. `faveo-redis` is the DNS name of the Redis container.

Finally, run the command below for changes to take effect.

```sh
docker compose down && docker compose up -d --build
```
---
---
