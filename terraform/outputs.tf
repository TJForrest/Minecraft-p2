output "minecraft_server_ip" {
	description = "Pub IP if MC server" 
	value       = aws_instance.app_server.public_ip
}

