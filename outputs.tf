output "master-public-ip" {
  value = aws_instance.master.public_ip
}

output "master-private-ip" {
  value = aws_instance.master.private_ip
}

output "worker-1-ip" {
  value = aws_instance.worker-1.private_ip
}

output "worker-2-ip" {
  value = aws_instance.worker-2.private_ip
}

output "FGTPublicIP" {
  value = aws_eip.FGTPublicIP.public_ip
}

output "FGTPrivateIP" {
  value = aws_instance.fgtvm.private_ip
}

output "FortigateUsername" {
  value = "admin"
}

output "FortiGatePassword" {
  value = aws_instance.fgtvm.id
}

output "FortiManagerPublicIP" {
  value = aws_eip.FMRPublicIP.public_ip
}

output "FortiManagerUsername" {
  value = "admin"
}

output "FortiManagerPassword" {
  value = aws_instance.fmrvm.id
}
