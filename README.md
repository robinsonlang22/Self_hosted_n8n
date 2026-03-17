# 🌩️ Enterprise AI Orchestration & Zero-Trust Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![n8n](https://img.shields.io/badge/n8n-Workflow_Automation-FF6D5A?logo=n8n&logoColor=white)](https://n8n.io/)

This repository contains several business logic workflows deploy on a self-hosted, enterprise-grade **n8n orchestration platform** which is built by Infrastructure as Code (IaC) and entirely deploy on Google Cloud. This architecture is designed to handle sensitive data pipelines by enforcing strict Zero-Trust security protocols and enabling advanced Large Language Model (LLM) orchestration.

---

## 🏗️ Part 1: Zero-Trust Cloud Architecture (Self-Hosting n8n)

Deploying commercial automation tools on public-facing ports introduces unacceptable security risks. This project implements a **Zero-Trust Network Architecture**, ensuring the backend infrastructure remains entirely inaccessible from the public internet.

### 🌟 Enterprise Infrastructure Highlights
**Google Identity-Aware Proxy (IAP)**: All administrative access to the n8n orchestration engine is intercepted and authenticated via Google OAuth at the edge. 
**Host-Based Traffic Routing**: The GCP Global Load Balancer dynamically routes traffic based on URL maps. Public endpoints can bypass IAP, e.g., homepage, while administrative and sensitive backends enforce strict identity verification, like n8n login page.
* **Publicly Inaccessible Backend**: The Google Compute Engine instance has no public ingress ports exposed for the application. GCP Firewall rules strictly limit inbound HTTP/HTTPS traffic exclusively to Google's Edge nodes (`35.191.0.0/16`, `130.211.0.0/22`).
* **Automated SSL & Internal Routing**: Public certificates are provisioned and managed globally via GCP Managed SSL, while internal container routing and automated DNS challenges are securely handled via Traefik v3.
* **Persistent Database**: Utilizes a robust PostgreSQL 16 database with automated health checks for workflow state management.

### 🚀 Infrastructure Deployment Guide

**1. Provision GCP Resources (Terraform)**
Ensure `keys/my_credentials.json` is configured and your variables are populated (note: sensitive variables like OAuth secrets are excluded from version control via `.gitignore`).
```bash
terraform init
terraform plan
terraform apply
```

**2. Initialize Orchestration Engine (Docker Compose)
SSH into the provisioned instance via the IAP Tunnel (allow-iap-ssh on port 22), configure your .env file, and one-click startup the services:
```bash
docker-compose up -d
```
Note: The GCP Global Load Balancer and managed SSL certificates may require 20-40 minutes to fully propagate globally upon initial deployment. To expedite the validation process, ensure your DNS records are set to "DNS Only" until the certificate status becomes ACTIVE. This allows Google's validation servers to directly reach your load balancer and verify domain ownership.

---

## 🤖 Part 2: Case Study Smart Weather Assistant
To demonstrate the platform's orchestration capabilities, this repository includes functional AI workflows that integrate external APIs, custom computing logic, and Large Language Models.

### 🌤️ Proof of Concept: Context-Aware LLM Assistant
File: projects/Halle-Weather-Assistant.json

While initially framed as a localized automated assistant, this workflow serves as a technical Proof of Concept (PoC) for context-aware data processing, real-time API integrations, and dynamic prompt engineering.

### ✨ Technical Workflow Capabilities
Dynamic Data Ingestion: High-fidelity data retrieval via REST APIs (Open-Meteo) triggered by highly specific Cron scheduling.

Native Compute Engine (JS): Utilizes n8n's Code Node to execute native JavaScript. It performs precise timezone reconciliation (UTC to Europe/Berlin) and calculates complex conditional logic (e.g., exact time deltas to sunrise/sunset based on ISO strings).

LLM Orchestration (Gemini 2.5 Flash):

Integrates Google's Gemini models via LangChain nodes.

Injects dynamic payloads (real-time temperature, time-to-event metrics) directly into the LLM prompt context.

Enforces strict output formatting and persona adoption (e.g., adjusting tone dynamically based on the day/night cycle calculations).

Automated Dispatch: Seamless webhook and API integration for downstream payload delivery (Telegram API).

### 🛠️ How to Import Workflows
Access your authenticated n8n instance.

Navigate to workflows and select "Import from File".

Choose the target JSON file (e.g., projects/Halle-Weather-Assistant.json).

In the n8n Credentials panel, configure the required API keys (e.g., Google Gemini Api account, Telegram account).

Activate the workflow to initiate the automated cron schedules.
