output "jumpbox-ip" {
  value = aws_instance.jumpbox.public_ip
}

output "master-ip" {
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

output "FortigateUsername" {
  value = "admin"
}

output "FortiGate-Password" {
  value = aws_instance.fgtvm.id
}

output "FortiManagerPublicIP" {
  value = aws_eip.FMRPublicIP.public_ip
}

output "FortigateUsername" {
  value = "admin"
}

output "FortiGate-Password" {
  value = aws_instance.fmrvm.id
}
