output "alb_dns_name" {
  description = "Open this URL in a browser to reach the application"
  value       = "http://${aws_lb.app.dns_name}"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "app_server_private_ip" {
  description = "Private IP of the app server (no public IP by design)"
  value       = aws_instance.app.private_ip
}

output "app_server_instance_id" {
  description = "Use with: aws ssm start-session --target <id>"
  value       = aws_instance.app.id
}

output "rds_endpoint" {
  description = "Private database endpoint (only resolvable/reachable inside the VPC)"
  value       = aws_db_instance.main.address
}

output "rds_publicly_accessible" {
  value = aws_db_instance.main.publicly_accessible
}

output "db_secret_arn" {
  description = "Secrets Manager ARN holding the auto-generated DB master password"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "flow_log_group" {
  value = aws_cloudwatch_log_group.flow_logs.name
}

output "cloudtrail_bucket" {
  value = aws_s3_bucket.cloudtrail.id
}
