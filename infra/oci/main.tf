provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key      = var.private_key
  region           = var.region
}

# --- 1. Container Registry ---
# Note: OCI Registry is usually created manually or via module, 
# but simply pushing to the path creates it if auto-creation is enabled in tenancy.
# We will use the namespace data source to build the URL.
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

# --- 2. Compute Instance ---
resource "oci_core_instance" "server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project_name}-box"
  shape               = "VM.Standard.E4.Flex" # AMD EPYC (Cost Effective)

  shape_config {
    ocpus         = 1
    memory_in_gbs = 4 # Generous RAM for staging
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = "<UBUNTU_22_04_OCID_FOR_YOUR_REGION>" 
    # Tip: Use a data source to find the latest Ubuntu image dynamically
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
      git_token    = var.github_token
      git_repo     = replace(var.github_repo_url, "https://", "")
      # Construct OCI Registry URL: <region-code>.ocir.io/<namespace>
      ecr_url      = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}"
      project_name = var.project_name
      region       = var.region
    }))
  }
}

# Helper to find ADs
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}