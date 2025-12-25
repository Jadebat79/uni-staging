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

