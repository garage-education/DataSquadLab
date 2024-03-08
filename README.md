# Data Squad - Platform Lab

## Live Coding: Building a Cloud Platform with AWS EKS and DevOps Tools
This is your one-stop shop to learn how to build a scalable and secure cloud platform with AWS EKS and essential DevOps tools. We'll dive deep into a live, interactive environment, so get ready to code alongside us!

### What We'll Be Building:
#### DevOps Tools: 🛠️
- Infrastructure as Code (IaC): Terraform 📜
- Continuous Integration and Continuous Deployment (CI/CD): GitHub/GitHub Actions ⚙️
- Observability: Prometheus, Loki, Grafana 📊
- Deployment Management: ArgoCD
#### Backend Configuration:
- Database (DB): Postgres RDS
- Application (App): Spring application deployed on Elastic Kubernetes Service (EKS)
#### Data Platform Components:
- Data Lake: Amazon S3
- Orchestration: Airflow
- ELT Process: DBT
- Data Ingestion: AWS Database Migration Service (DMS)
- Data Warehouse (DWH): Amazon Redshift
- Reporting Tool: Metabase

## Why Follow Along?
- Learn by Doing: Forget pre-recorded perfection. We'll embrace the "real world" by encountering and fixing errors together, providing valuable troubleshooting experience.
- Hands-on Learning: Create an AWS account and follow along with the steps. This is your chance to build your own platform alongside us!
- Focus on Practical Skills: We'll prioritize the tools and techniques you can use immediately, not just theoretical concepts.
- Beginner-Friendly: No prior knowledge of everything is required. We'll break down complex topics into manageable steps.
- Embrace Mistakes: Learning happens through doing, and making mistakes is inevitable. We'll learn from them together!
- Peer Programming: This live format fosters collaboration and discussion, encouraging peer programming techniques.

## Questions
- [ ] Should we have one account for dev, uat, and prod?
- [ ] How to do inplace modification for critical usecases? Ex. Change storage for the database
- [ ] Can we use advanced analytics window functions on mongo DB?

## AWS Deployment
### Architecture Design
- ContainerDiagram
![Architecture-ContainerDiagram.jpg](aws%2Farchitecture-diagrams%2FArchitecture-ContainerDiagram.jpg)
- Network Topology
![Architecture-Network Topology.jpg](aws%2Farchitecture-diagrams%2FArchitecture-Network%20Topology.jpg)
- Deployment Diagram
![Architecture-DeploymentDiagram.jpg](aws%2Farchitecture-diagrams%2FArchitecture-DeploymentDiagram.jpg)
### Execution checklist
- [x] Terraform
	- [x] Administrator User
	- [x] Configure local CLI
	- [x] Terraform S3 Bucket
- [x] VPC
	- [x] CIDRs
	- [x] Availability zones
	- [x] Infra, Private subnet, Public Subnet
	- [x] NAT Gateway
- [ ] IAM
	- [ ] OIDC Provider
	- [ ] Github OIDC
	- [ ] ECR OIDC
- [x] S3
	- [x] Landing zone
	- [x] Archive
	- [x] Logs
- [ ] RDS
	- [ ] Secret manager
	- [x] Parameter groups
	- [x] Security groups
	- [x] Postgres
	- [ ] BE Database
- [ ] Secret Manager
	- [ ] Rotate secrets
- [x] EKS
	- [x] VPC-CNI and IRSA
	- [x] Node Group
	- [ ] EBS-CSI and IRSA
- [ ] Applications
	- [ ] External Secret Operator
	- [ ] Nginx Ingress
	- [ ] Cert-Manager
	- [ ] ArgoCD
	- [ ] Grafana
	- [ ] Prometheus
	- [ ] Loki
	- [ ] Pet Clinic
	- [ ] Metabase
	- [ ] Airflow
