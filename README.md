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

**Public DNS:** http://ec2-15-222-10-193.ca-central-1.compute.amazonaws.com

**What I verified**
- EC2 in ca-central-1 is running and reachable over HTTP (80)
- NGINX serves a page with Region, AZ, and Instance ID

**Screenshot**


![Day 1 Hello](demo/failover-test-screenshots/day1-hello.png)


## Day 2 — Custom VPC + Public/Private Subnets (Result)

**Public DNS:** http://ec2-3-96-191-145.ca-central-1.compute.amazonaws.com/

**What I built**
- New VPC (`10.31.0.0/16`) with 2 public and 2 private subnets across 2 AZs
- Internet Gateway + public route table (0.0.0.0/0 → IGW)
- Security group allowing HTTP(80) and SSH(22) for demo
- One EC2 (t3.micro) in Public Subnet 1 serving NGINX

**Screenshot**

![Day 2 — Custom VPC](demo/failover-test-screenshots/day2.png)
## Day 3 — Auto Scaling Group (ASG)

**What I built**
- Launch Template + Auto Scaling Group (min/desired/max = 1) in my Day-2 VPC
- Security Group allows HTTP(80) + SSH(22)
- CloudWatch alarm: in-service instances < 1

**What I tested**
- Reached the ASG-backed instance at http://ec2-99-79-67-101.ca-central-1.compute.amazonaws.com/
- Terminated the instance; ASG launched a replacement automatically

**Screenshot**

![Day 3 — ASG](demo/failover-test-screenshots/day3-asg.png)


## Day 4 — Secondary Region (us-east-1)

**Public DNS:** http://ec2-3-237-201-160.compute-1.amazonaws.com/

**What I built**
- Separate VPC in us-east-1 with 2 public + 2 private subnets
- ASG (min/desired/max = 1) serving the same NGINX page

**Screenshot**

![Day 4 — Secondary](demo/failover-test-screenshots/day4-secondary.png) 
## Regional Failover Demonstration (no custom domain) 

**Goal:** Prove that the application can continue serving traffic from a **secondary region** when the **primary region** becomes unavailable.

### Architecture
- **Primary:** ca-central-1 — Auto Scaling Group (desired=1) serving NGINX
- **Secondary:** us-east-1 — Auto Scaling Group (desired=1) serving the same page
- **Health Signal:** HTTP 200 from `/`
- **Client Fallback Tester:** A small PowerShell loop that hits the primary; on failure, it falls back to the secondary

### Endpoints
- Primary: http://ec2-15-156-193-103.ca-central-1.compute.amazonaws.com/

- Secondary: http://ec2-34-201-48-251.compute-1.amazonaws.com/

### What I did
1. Verified the primary endpoint returns **200 OK**.
2. Ran a **fallback tester** (`demo/failover_tester.ps1`) that polls the primary and automatically switches to the secondary if the primary fails.
3. **Simulated an outage** by scaling the primary ASG to zero instances.
4. Observed the tester switch from `PRIMARY OK` to `PRIMARY FAIL -> fallback` and then `SECONDARY OK`.
5. **Restored** the primary ASG and confirmed traffic returned to `PRIMARY OK`.

### Commands I used (for reproducibility)

Scale primary to 0 (simulate failure):
`bash
ASG_PRI=$(aws cloudformation describe-stack-resource \
  --stack-name dr-day3-asg \
  --logical-resource-id ASG \
  --region ca-central-1 \
  --query "StackResourceDetail.PhysicalResourceId" --output text)

aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name "$ASG_PRI" \
  --desired-capacity 0 --min-size 0 \
  --region ca-central-1
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name "$ASG_PRI" \
  --desired-capacity 1 --min-size 1 \
  --region ca-central-1

**Screenshots**

![Day 4 — Before (Primary OK)](demo/failover-test-screenshots/day4-failover-before.png)
![Day 4 — After (Secondary Serving)](demo/failover-test-screenshots/day4-failover-after.png)

## Day 5 — S3 Cross-Region Replication (CRR)

**What I built**
- Versioned, encrypted S3 buckets in two regions:
  - Source (ca-central-1): `s3://<YOUR_SRC_BUCKET>`
  - Destination (us-east-1): `s3://<YOUR_DST_BUCKET>`
- IAM replication role assumed by S3
- Replication rule: all objects from source → destination

**What I tested**
- Uploaded `demo/inventory.csv` to the source bucket
- Verified the object appeared in the destination bucket automatically

**Screenshots**

![Day 5 — Source](demo/failover-test-screenshots/day5-s3-src.png)
![Day 5 — Destination](demo/failover-test-screenshots/day5-s3-dest.png)
![Day 5 — Destination](demo/failover-test-screenshots/day5-s3-dest-details.png)


