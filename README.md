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

## 🤖 Part 2: AI Automation Workflows
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

---

## 🔮 Future Roadmap: Compliance-First AI workflow: integrate HITL & RLHF
The next evolution of this platform focuses on high-stakes commercial compliance by implementing Human-in-the-Loop (HITL) and Reinforcement Learning from Human Feedback (RLHF). This phase demonstrates how to constrain Large Language Models (LLMs) to ensure output quality, mitigate hallucinations, and maintain professional rigor.

### 🎯 Objective: Corporate-Aligned AI Communication
Instead of allowing autonomous agents to operate without oversight, this workflow enforces a multi-stage validation process for customer-facing content (Emails, Support Tickets, Quotes).

1. Constrained Generation (The AI Agent)Brand & Persona Alignment: AI agents are grounded in specific corporate "Brand Voice" documents.Product Parameter Ingestion: The model is fed real-time product specifications and technical constraints to prevent factual errors.Hallucination Mitigation: By using Retrieval-Augmented Generation (RAG) combined with strict system prompts, the model is restricted from making unauthorized promises or inventing product capabilities.
2. Human-in-the-Loop (HITL) ValidationIsolation of Edge Cases: Low-confidence outputs or sensitive inquiries (e.g., refund requests, medical data queries) are automatically flagged and routed to a secure human-operator interface.The "Wait for Approval" Gate: Utilizing n8n's asynchronous webhook nodes, the workflow pauses execution until a human reviews the draft via a custom, IAP-protected dashboard.Manual Correction: Operators can approve, reject, or "edit-to-fix" the AI’s draft, ensuring 100% compliance before the final payload is dispatched.
3. Data Collection for RLHFFeedback Logging: Every human intervention (edit or rejection) is logged as a "correction pair."Model Optimization: This structured data serves as the foundation for Reinforcement Learning from Human Feedback. Over time, these correction pairs are used to fine-tune the model's reward system, training the AI to "prefer" the tone and accuracy favored by human experts.

### 🛡️ Business Value: Quality & Robustness
1. Error Prevention: Eliminates the risk of "rogue AI" damaging brand reputation through impolite or inaccurate responses.
2. Operational Scalability: Allows a small team of human experts to oversee thousands of AI-generated messages, only intervening where the AI's confidence score falls below a set threshold.
3. Compliance Ready: Provides a full audit trail of who approved what content and when—a mandatory requirement for medical, legal, and financial sectors.

### 🚀 Implementation PreviewThe upcoming workflow will feature:
1. Sentiment & Tone Analysis: Pre-check nodes to verify professional etiquette.
2. Secure Operator Portal: An IAP-authenticated internal site for human reviewers.
3. Automated Feedback Loop: A PostgreSQL-based logging system to store "Human-Approved" vs "AI-Original" text for future RLHF fine-tuning.

