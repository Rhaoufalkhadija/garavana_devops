output "master_public_ip" {
  description = "IP publique du nœud master"
  value       = aws_instance.master.public_ip
}

output "worker_public_ip" {
  description = "IP publique du nœud worker"
  value       = aws_instance.worker.public_ip
}

output "master_instance_id" {
  description = "Instance ID du master"
  value       = aws_instance.master.id
}

output "worker_instance_id" {
  description = "Instance ID du worker"
  value       = aws_instance.worker.id
}

output "dashboard_url" {
  description = "URL du dashboard Garavana"
  value       = "http://${aws_instance.worker.public_ip}:30080/dashboard"
}

output "jenkins_url" {
  description = "URL Jenkins"
  value       = "http://${aws_instance.master.public_ip}:8080"
}
