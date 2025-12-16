# 1. Dynamic Group (Selects our instance)
resource "oci_identity_dynamic_group" "server_group" {
  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-dg"
  description    = "Dynamic group for staging server"
  
  # Logic: "ANY instance in this compartment with this specific ID"
  matching_rule = "ALL {instance.id = '${oci_core_instance.server.id}'}"
}

# 2. Policy (Grants permission)
resource "oci_identity_policy" "server_policy" {
  compartment_id = var.compartment_ocid
  name           = "${var.project_name}-policy"
  description    = "Allow server to read secrets and registry"

  statements = [
    # Allow reading secrets
    "Allow dynamic-group ${oci_identity_dynamic_group.server_group.name} to read secret-bundles in compartment id ${var.compartment_ocid}",
    # Allow pulling images (if repo is private)
    "Allow dynamic-group ${oci_identity_dynamic_group.server_group.name} to read repos in compartment id ${var.compartment_ocid}"
  ]
}