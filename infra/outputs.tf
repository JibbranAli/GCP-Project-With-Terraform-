output "load_balancer_ip" {
  description = "External IP address of the HTTP load balancer."
  value       = google_compute_global_address.web.address
}

output "load_balancer_url" {
  description = "URL for the web app."
  value       = "http://${google_compute_global_address.web.address}"
}

output "static_bucket_name" {
  description = "Cloud Storage bucket for static assets."
  value       = google_storage_bucket.static_assets.name
}

output "vpc_name" {
  description = "VPC name."
  value       = google_compute_network.vpc.name
}


