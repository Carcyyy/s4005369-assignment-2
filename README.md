# COSC2759 Assignment 2, 2023

## Student Details

- Full Name: Carlson Mun
- Student ID: s4005369

## Overview of My Solution

This project is all about setting up a reliable and secure environment for a Node.js app with a PostgreSQL database on AWS. Here's how I designed and deployed everything to meet the requirements:

### Infrastructure Setup

- **EC2 Instances**: I used AWS EC2 instances to host both the Node.js app and the PostgreSQL database.
  - Two instances run the app, and they are placed behind a load balancer so they can handle more traffic and stay online even if one instance goes down.
  - One instance hosts the PostgreSQL database. It connects securely to the app instances over a private IP.

- **Load Balancer**: To keep things balanced, I used an AWS Elastic Load Balancer (ELB). This ELB makes sure the incoming requests are distributed evenly across the two app instances, which helps keep the app available even if something fails.

- **Security Groups**: Security is key, so I set up two main security groups:
  1. **App Security Group**: This allows HTTP traffic (port 80) for the web app and SSH access (port 22) for management.
  2. **Database Security Group**: Allows traffic on port 5432 (PostgreSQL) only from the app's private IP addresses and SSH access for managing the database.

- **AWS S3 and Terraform State**: I'm using an S3 bucket to keep the Terraform state files in one place. This helps to collaborate better and keeps track of changes safely.

- **Private Networking**: The communication between the app servers and the database happens over a private subnet, which makes it more secure and prevents public access to the database.

### How Data Flows Through the System

1. **Client Requests**: Users connect through a web browser. Requests first go to the load balancer.
2. **Load Balancer**: The load balancer passes the request to one of the available app instances.
3. **App Server**: The Node.js app handles the request. If it needs data, it will send a query to the PostgreSQL database.
4. **Database**: The database processes the request and sends the result back to the app server.
5. **Response to Client**: The app server processes the data and sends a response back to the user via the load balancer.

This setup keeps things efficient and secure while providing high availability.

### How I Deployed Everything

To deploy this solution, I used **Terraform** for provisioning resources and **Ansible** for configuring the servers. There's also a backup plan using a shell script, just in case GitHub Actions is down.

#### Prerequisites

- **Terraform** and **Ansible** installed locally.
- **AWS credentials** configured via GitHub secrets.
- **SSH private key** stored in GitHub secrets for secure access to EC2 instances.

#### GitHub Actions Workflow

*The GitHub Actions workflow handles most of the deployment automatically:*
- It kicks off the process when I push to the `main` branch.
- It installs the necessary tools (like Terraform and Ansible).
- It uses AWS credentials stored in secrets to authenticate.
- Terraform provisions the infrastructure, and Ansible configures the servers.

#### Backup Plan: Deploying with a Shell Script

I also have a `deploy.sh` script as a backup if GitHub Actions fails.
- The script ensures Terraform and Ansible are installed and runs the deployment commands manually.
- It's a simple way to bring everything up without needing automation tools.

#### Testing the App

After deployment, I check that the app is up and running:
1. I use the load balancer URL to make sure the app responds.
2. If there are issues, I SSH into the EC2 instances to check logs and troubleshoot.

### What's in This Repository?

- `terraform/`: Holds the Terraform files for infrastructure.
- `ansible/`: Contains playbooks for configuring servers.
- `.github/workflows/`: GitHub Actions workflow for automating deployment.
- `scripts/`: Useful scripts like `manage_ansible.sh` for managing Ansible runs.
- `README.md`: This document, describing the whole setup.

This approach helped me build a secure, scalable setup for the Foo app, ensuring it runs reliably and efficiently.

