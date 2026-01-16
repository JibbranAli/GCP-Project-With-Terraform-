locals {
  name_prefix       = var.name_prefix != "" ? var.name_prefix : "webapp"
  lb_source_ranges  = ["130.211.0.0/22", "35.191.0.0/16"]
  startup_script = <<-EOT
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>${local.name_prefix} - $(hostname)</h1>" > /var/www/html/index.html
  EOT
}

