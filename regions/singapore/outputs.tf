output "singapore_instance_id" {
  value = module.ec2.instance_id
}

output "singapore_public_ip" {
  description = "Public IP - Singapore"
  value       = module.ec2.public_ip
}

output "singapore_public_dns" {
  value = module.ec2.public_dns
}