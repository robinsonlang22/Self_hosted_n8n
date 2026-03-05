# 🌩️ Enterprise AI Orchestration & Zero-Trust Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![n8n](https://img.shields.io/badge/n8n-Workflow_Automation-FF6D5A?logo=n8n&logoColor=white)](https://n8n.io/)

This repository contains an Infrastructure as Code (IaC) deployment and business logic workflows for a self-hosted, enterprise-grade **n8n orchestration platform**. 

[cite_start]Built entirely on Google Cloud Platform (GCP)[cite: 9], this architecture is designed to handle sensitive data pipelines (such as automated payload parsing and AI-assisted data screening) by enforcing strict Zero-Trust security protocols and enabling advanced Large Language Model (LLM) orchestration.

---

## 🏗️ Part 1: Zero-Trust Cloud Architecture (Self-Hosted n8n)

Deploying commercial automation tools on public-facing ports introduces unacceptable security risks. This project implements a **Zero-Trust Network Architecture**, ensuring the backend infrastructure remains entirely inaccessible from the public internet.



### 🌟 Enterprise Infrastructure Highlights
* [cite_start]**Google Identity-Aware Proxy (IAP)**: All administrative access to the n8n orchestration engine is intercepted and authenticated via Google OAuth at the edge[cite: 4, 16]. 
* [cite_start]**Host-Based Traffic Routing**: The GCP Global Load Balancer dynamically routes traffic based on URL maps[cite: 6]. [cite_start]Public endpoints can bypass IAP [cite: 3][cite_start], while administrative and sensitive backends enforce strict identity verification[cite: 4].
* **Publicly Inaccessible Backend**: The Google Compute Engine instance has no public ingress ports exposed for the application. [cite_start]GCP Firewall rules strictly limit inbound HTTP/HTTPS traffic exclusively to Google's Edge nodes (`35.191.0.0/16`, `130.211.0.0/22`)[cite: 5, 15].
* [cite_start]**Automated SSL & Internal Routing**: Public certificates are provisioned and managed globally via GCP Managed SSL[cite: 7], while internal container routing and automated DNS challenges are securely handled via Traefik v3.
* **Persistent Database**: Utilizes a robust PostgreSQL 16 database with automated health checks for workflow state management.

### 🚀 Infrastructure Deployment Guide

**1. Provision GCP Resources (Terraform)**
[cite_start]Ensure `keys/my_credentials.json` is configured [cite: 14] and your variables are populated (note: sensitive variables like OAuth secrets are excluded from version control via `.gitignore`).
```bash
terraform init
terraform plan
terraform apply
