output "control_plane_instance_public_ip" {
  description = "Public IP of EC2 control plane"
  value       = aws_instance.k8s_control_plane
}

output "instance_public_ip" {
  description = "Public IP of EC2 worker nodes"
  value       = aws_instance.k8s_worker_plane[*].public_ip
}