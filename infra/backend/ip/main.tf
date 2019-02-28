resource "google_compute_address" "default" {
  name          = "${terraform.workspace}-ip"
}