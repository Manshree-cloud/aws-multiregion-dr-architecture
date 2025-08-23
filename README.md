# Project 1 — Multi-Region Disaster Recovery (from scratch)

**Primary Region:** ca-central-1 (Canada Central)  
**Secondary Region:** us-east-1 (N. Virginia)

## Goal
Build a cost-optimized, reproducible multi-region DR reference on AWS using CloudFormation.

## Roadmap
- [ ] Day 1: Hello World EC2 (default VPC) + NGINX
- [ ] Day 2: Custom VPC with public/private subnets (primary)
- [ ] Day 3: Auto Scaling Group (primary)
- [ ] Day 4: Secondary region EC2/ASG
- [ ] Day 5: S3 Cross-Region Replication
- [ ] Day 6: Route 53 failover (health checks)
- [ ] Day 7: RDS Multi-AZ (primary) + alarms
- [ ] Docs: Architecture diagram + screenshots + cleanup

## How to run (Day 1)
See commands in `/cloudformation/day1-ec2.yml` section of this README.
## Day 1 — Result

**Public DNS:** `http://ec2-15-222-10-193.ca-central-1.compute.amazonaws.com`

**What I verified**
- EC2 in ca-central-1 is running and reachable over HTTP (80)
- NGINX serves a page with Region, AZ, and Instance ID

**Screenshot**


![Day 1 Hello](demo/failover-test-screenshots/day1-hello.png)


## Day 2 — Custom VPC + Public/Private Subnets (Result)

**Public DNS:** `http://<YOUR_DNS>`

**What I built**
- New VPC (`10.31.0.0/16`) with 2 public and 2 private subnets across 2 AZs
- Internet Gateway + public route table (0.0.0.0/0 → IGW)
- Security group allowing HTTP(80) and SSH(22) for demo
- One EC2 (t3.micro) in Public Subnet 1 serving NGINX

**Screenshot**

![Day 2 — Custom VPC](demo/failover-test-screenshots/day2-custom-vpc.png)



