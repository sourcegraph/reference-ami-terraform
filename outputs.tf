output "Sourcegraph_URL" {
    value = "https://${var.dns_host_name}.${var.dns_domain_name}"
}
