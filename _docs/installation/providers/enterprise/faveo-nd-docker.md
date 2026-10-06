---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/faveo-nd-docker/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-09-29
last_modified_by: Sivakumar_C
toc: true
---
---
# <b>Deploying Faveo Network Discovery on Docker</b>   <!-- omit in toc -->
<img src="https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4e/Docker_%28container_engine%29_logo.svg/960px-Docker_%28container_engine%29_logo.svg.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=thumbnail" alt="drawing" width="300"/>

## <b>Faveo Network Discovery Docker</b>

A pretty simplified Docker Compose workflow that sets up a network of containers for Faveo Network Discovery.

## <b>Usage</b>
To get started, make sure you have Docker and Docker-Compose installed on your system, and then clone the below Git-Hub repository with the below command.

```sh
git clone https://github.com/ladybirdweb/faveo-helpdesk-docker-v2.git
```
---
```
cd faveo-helpdesk-docker-v2/faveo-nd-docker
```
Next, navigate in your terminal to the directory you cloned this, and give the executable permissions to bash scripts.

```sh
chmod +x faveo-run.sh
```
### <b>Prerequisites To run the script:</b>

1. A valid domain name fully propagated to your Server's IP.
2. Sudo Privilege.
3. Faveo ND license and Order number. (This can be obtained from <a href="https://billing.faveohelpdesk.com" target="_blank" rel="noopener">billing.faveohelpdesk.com</a>).
4. Unreserved ports 80 and 443. (If it is reserved feel free to edit and change the ports of your choice in docker-copompose.yml)
5. Operating Systems Ubuntu 22,24
6. SSL Certificate (For Paid SSL Users), If you're using a paid SSL, have the SSL certificate files ready before installation.

Complete the below steps to get the Containers up.

Run the script <code><b>faveo-run.sh</b></code> by passing the necessary arguments.

**NOTE:** You should have a Valid domain name pointing to your public IP. This domain name is used to obtain SSL certificates, and the mail is used for the same purpose. The license code and Order Number can be obtained from your Faveo Helpdesk Billing portal, and make sure not to include the '#' character in the Order Number.

**SSL Certificate Options:** Pass the option based on your SSL requirement

- Option A: Let’s Encrypt (Free SSL)

- Option B: Self-Signed SSL

- Option C: Paid SSL (
  
  Incase of Paid SSL, please ensure your SSL files are ready in your system. If you choose Option C (Paid SSL), you must specify the paths of the SSL certificate files.

SSL Certificate Path: */path/to/certificate.crt*

SSL Key Path: */path/to/private.key*

SSL CA Bundle : */path/to/ca_bundle.crt*

Usage:
```sh
 ./faveo-run.sh -domainname <your domainname> -email <example@email.com> -license <faveo license code> -orderno <faveo order number> -ssl <SSL Option>
```
Example: It should look something like this.
```sh
 ./faveo-run.sh -domainname yourdomainname.com -email youremail@gmail.com -license 5H876********** -orderno 8123****** -ssl <A|B|C>
```
---

After the docker installation is completed you will be prompted with Database Credentials and Credentials are saved in filename <code><b>credentials.txt</b></code>  them somewhere safe and a cronjob will be set to auto-renew SSL certificates from Letsencrypt.

Visit  <code><b>https://yourdomainname.com</b></code> complete the readiness probe, input the Database Details when prompted, and complete the installation.

There is one final step that needs to be done to complete the installation. 

You have to edit the <code><b>.env</b></code> file which is generated under the Faveo root directory after completing the installation in the browser. 

Open the terminal and navigate to the faveo-docker directory here you will find the directory <code><b>faveo</b></code> which is downloaded while running the script this directory contains all the Faveo Network Discovery codebase, inside it, you need to edit the <code><b>.env</b></code>  file and add <code><b>REDIS_HOST=faveo-redis</b></code>. The "faveo-redis" is the DNS name of the Redis container. 

Finally, run the below command for changes to take effect.

```sh
docker compose down && docker compose up -d
```
---