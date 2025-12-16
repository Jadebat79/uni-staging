output "public_ip" {
  description = "Public IP of the staging server (Add to DNS A-Record)"
  value       = oci_core_instance.server.public_ip
}

output "instance_ocid" {
  description = "The Oracle Cloud ID of the server (For CLI debugging)"
  value       = oci_core_instance.server.id
}

output "ocir_registry_url" {
  description = "The Base URL for pushing Docker images (Add to GitHub Secrets)"
  # Constructs: <region-code>.ocir.io/<tenancy_namespace>
  value       = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}"
}

output "ssh_connection_string" {
  description = "Command to SSH into the box (if using keys)"
  value       = "ssh -i <path_to_private_key> ubuntu@${oci_core_instance.server.public_ip}"
}