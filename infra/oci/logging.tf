// OCI Logging resources for container logs
// Fluent Bit on the instance will ship Docker logs to this custom log.

resource "oci_logging_log_group" "staging" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-log-group"
  description    = "Log group for staging container logs"
}

resource "oci_logging_log" "staging_containers" {
  display_name = "${var.project_name}-containers"
  log_group_id = oci_logging_log_group.staging.id

  // CUSTOM log type for arbitrary JSON logs from Fluent Bit
  log_type   = "CUSTOM"
  is_enabled = true

  // Note: retention is configured at the group level in OCI by default.
  // If you want to override it, add the appropriate configuration here
  // based on your tenancy defaults.

  configuration {
    source {
      category = "custom"
      // These fields are mostly tags/metadata; they do not have to match real services.
      resource = "docker"
      service  = "containers"
    }
  }
}


