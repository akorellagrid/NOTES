# Terraform — Part 4 AWS infrastructure

Implements [`docs/aws-architecture.md`](../docs/aws-architecture.md):
two regions (`ap-south-1` primary, `ap-southeast-1` secondary), each with
a horizontally-scaling ASG behind an ALB in private subnets, a single
RDS instance in the primary region only, and a cross-region private
link so the secondary region's app tier can reach it.

Built against a Free Tier account — see §6 of the design doc and the
inline comments for what's substituted for cost (NAT instance instead
of NAT Gateway, `t3.micro` / `db.t3.micro` throughout, `desired_capacity
= 1`).

## Layout

```
infra/
  modules/
    network/     VPC, public/private/db subnets, NAT instance, routing
    security/    ALB / app / db security groups
    compute/     launch template, ASG, target-tracking policy, ALB
    database/    RDS single instance + Secrets Manager credential
    registry/    ECR repo + cross-region replication
  environments/
    primary/     ap-south-1 — network + security + registry + database + compute
    secondary/   ap-southeast-1 — network + security + compute only
  global/        VPC peering + optional Route 53 latency routing
```

Each environment holds its own local state file. `secondary` and
`global` read `primary`'s (and `secondary`'s) state via
`terraform_remote_state`, so apply order matters.

## Prerequisites

- Terraform >= 1.5, AWS provider ~> 5.0
- AWS credentials configured (`aws sts get-caller-identity` should work)
- The app image built and ready to push: `docker build -t notes-api ..`
  from the repo root (uses the existing [`Dockerfile`](../Dockerfile))

## Apply order

```bash
# 1. Primary region — creates the ECR repo, RDS instance, and primary ALB/ASG
cd infra/environments/primary
terraform init
terraform apply

# Push the app image to the ECR repo this just created
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin "$(terraform output -raw ecr_repository_url | cut -d/ -f1)"
docker tag notes-api:latest "$(terraform output -raw ecr_repository_url):latest"
docker push "$(terraform output -raw ecr_repository_url):latest"

# 2. Secondary region — reads primary's state for the replicated
#    ECR image and DB secret ARN
cd ../secondary
terraform init
terraform apply

# 3. Global — VPC peering between the two regions, optional Route 53
cd ../../global
terraform init
terraform apply
```

Tear down in reverse order (`global` → `secondary` → `primary`) to
avoid leaving a NAT instance, ALB, or RDS instance billing in the
background.

## Variables worth setting

- `certificate_arn` (primary & secondary) — a regional ACM certificate
  ARN if you want HTTPS on the ALB. Left blank, the ALB serves HTTP
  only.
- `create_dns_records`, `hosted_zone_id`, `record_name` (global) — only
  set these if you own a domain already in Route 53. Otherwise, test
  each region directly via `terraform output alb_dns_name` in the
  respective environment.

## Known limitations (by design)

- Local Terraform state, no S3/DynamoDB backend — fine for a capstone,
  not for a team. A real deployment would move to a remote backend
  with state locking.
- NAT instance instead of NAT Gateway — a Free Tier cost substitution,
  not a production pattern. NAT Gateway is a straightforward swap in
  `modules/network` once cost isn't a constraint.
- Single RDS instance is a single point of failure for both regions —
  this is requirement 3, not an oversight. See §5 of the design doc.
