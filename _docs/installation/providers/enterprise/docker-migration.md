---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/docker-migration/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-04-12
last_modified_by: Mohammad_Asif
toc: true
title: Faveo Helpdesk Migration to Docker
---
<img src="https://upload.wikimedia.org/wikipedia/commons/1/1e/Docker_Logo.png" alt="drawing" width="300"/>

This documentation outlines the step-by-step process for migrating Faveo Helpdesk from a legacy server to a Dockerized environment.

# Migration Steps

## Steps on the Old Server


### 1. Take File System Backup
Create a compressed archive of the Faveo file system on the old server:
```
zip -r faveo-fs-bkp-dd-mm-yy.zip /path/to/faveo
```

### 2. Take Database Backup
Export the Faveo database into an SQL file:
```
mysqldump -u user -ppassword faveo > faveo-db-bkp-dd-mm-yy.sql
```

### 3. Transfer Backup Files to the New Server
Use scp to copy the file system and database backups to the new server:
```
scp faveo-fs-bkp-dd-mm-yy.zip user@new_server_ip:/path/to/destination
scp faveo-db-bkp-dd-mm-yy.sql user@new_server_ip:/path/to/destination
```

## Steps on the New Server

### 1. Install Faveo Using Docker
Follow the official Faveo Docker installation documentation at the link below to install Faveo on the new server: <a href="https://docs.faveohelpdesk.com/docs/installation/providers/enterprise/faveo-helpdesk-docker/" target="_blank" rel="noopener">`Faveo Docker Installation Guide`</a> 

This step will create a directory named `faveo-helpdesk-docker-v2/faveo` and deploy the necessary Docker containers.

### 2. Copy the Database Backup to the MySQL Container
Transfer the database backup file into the running MySQL container:
```
docker cp faveo-db-bkp-dd-mm-yy.sql <mysql_container_id>:/path/inside/container
```

### 3. Import the Database into the Faveo MySQL Container
Restore the database backup:
```
docker exec -i <mysql_container_id> 
mysql -u user -ppassword faveo < /path/inside/container/faveo-db-bkp-dd-mm-yy.sql
```

### 4. Rename Existing Faveo Directory
Rename the existing Faveo directory (created by Docker) to keep it as a backup:
```
mv faveo-helpdesk-docker-v2/faveo faveo-helpdesk-docker-v2/faveo-old
```

### 5. Create a New Faveo Directory
Create a new directory for Faveo:
```
mkdir -p faveo-helpdesk-docker-v2/faveo
```

### 6. Unzip the File System Backup
Unzip the file system backup to the new Faveo directory:
```
unzip faveo-fs-bkp-dd-mm-yy.zip -d faveo-helpdesk-docker-v2/faveo
```

### 7. Set Correct Ownership
Change the ownership of the files to www-data to ensure proper permissions:
```
chown -R www-data:www-data faveo-helpdesk-docker-v2/faveo
```

### 8. Update the .env File
Edit the `.env` file in the `faveo-helpdesk-docker-v2/faveo` directory to reflect the new database credentials:
```
DB_HOST="localhost"  
DB_DATABASE="faveo"
DB_USERNAME="faveo"
DB_PASSWORD="YOUR-PASSWORD"
```

### 9. Restart Docker Containers
After completing the configuration changes, restart the Docker containers:
```
docker compose down && docker compose up -d
```

## Final Steps

- Verify that the migration has completed successfully by accessing the Faveo Helpdesk in your browser.
- Test the functionality and ensure data integrity after the migration.