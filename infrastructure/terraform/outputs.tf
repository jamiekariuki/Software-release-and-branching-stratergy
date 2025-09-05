output "web_instance_public_ip" {
  value = module.ec2_instance.public_ip
}

output "ecr_repo_uri" {
  value = module.ecr.repository_url
}


