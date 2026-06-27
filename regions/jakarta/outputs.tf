output "jakarta_instance_id" {
  value = module.ec2.instance_id
}

output "jakarta_public_ip" {
  description = "Public IP - Jakarta"
  value       = module.ec2.public_ip
}

output "jakarta_public_dns" {
  value = module.ec2.public_dns
}