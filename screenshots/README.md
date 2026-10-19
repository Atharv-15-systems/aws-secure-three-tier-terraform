# Screenshots Checklist

Take these after `terraform apply` succeeds, save them in this folder using the suggested names, and make sure **no account ID / secrets / passwords** are visible (blur if needed).

| # | Filename | What to capture | Proves |
|---|---|---|---|
| 1 | `01-terraform-apply.png` | Terminal showing `Apply complete! Resources: ~50 added` and the outputs | Successful deployment |
| 2 | `02-vpc-subnets.png` | VPC Console → Subnets, filtered to your VPC (6 subnets, 2 AZs) | Req. 1 |
| 3 | `03-route-tables.png` | Route tables: public (→ igw), private-app (→ nat), private-db (local only) | Req. 5 |
| 4 | `04-igw-nat.png` | Internet Gateway and NAT Gateway pages | Req. 5 |
| 5 | `05-alb.png` | EC2 → Load Balancers: scheme "internet-facing", public subnets | Req. 2 |
| 6 | `06-target-healthy.png` | Target group showing the instance as **healthy** | ALB → EC2 works |
| 7 | `07-app-in-browser.png` | Browser opened on the `alb_dns_name` URL | End-to-end works |
| 8 | `08-ec2-no-public-ip.png` | EC2 instance details: no public IPv4, private subnet | Req. 3 |
| 9 | `09-rds-not-public.png` | RDS → Connectivity: "Publicly accessible: No", DB subnet group | Req. 4, 6 |
| 10 | `10-security-groups.png` | Inbound rules of ALB-SG, App-SG (source = ALB SG), DB-SG (source = App SG) | Req. 5, 6 |
| 11 | `11-db-connect-from-app.png` | SSM session on app server successfully connecting with `mysql -h ...` | DB reachable from app |
| 12 | `12-flow-logs.png` | VPC → Flow logs tab (status Active) and CloudWatch log group with entries | Req. 7 |
| 13 | `13-cloudtrail.png` | CloudTrail trail (logging on) and/or Event history | Req. 7 |
| 14 | `14-cloudtrail-s3.png` | S3 bucket containing `AWSLogs/` objects, public access blocked | Req. 7 |

Optional strong evidence: a CloudWatch Logs Insights result showing a `REJECT` flow, e.g. try `mysql` to the DB from your own laptop (it will time out) and show the rejected traffic in the logs.
