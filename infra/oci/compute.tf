# --- 2. Compute Instance ---
resource "oci_core_instance" "server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project_name}-box"
  shape               = "VM.Standard.A1.Flex" # AMD EPYC (Cost Effective)

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12 # Generous RAM for staging
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = "Canonical-Ubuntu-24.04-aarch64-2025.12.09-0" 
    # Tip: Use a data source to find the latest Ubuntu image dynamically
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
      GIT_TOKEN       = var.github_token
      GIT_REPO        = replace(var.github_repo_url, "https://", "")
      PROJECT_NAME    = var.project_name
      OCI_REGION      = var.region
      TENANCY_OCID    = var.tenancy_ocid
      COMPARTMENT_OCID = var.compartment_ocid
      DOMAIN_NAME     = var.domain_name
      OFFICE_IP       = var.office_ip
      GHCR_TOKEN      = var.ghcr_token
      GHCR_USERNAME   = var.ghcr_username
      OCI_LOG_ID      = oci_logging_log.staging_containers.id
    }))
  }
}

# Helper to find ADs
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}