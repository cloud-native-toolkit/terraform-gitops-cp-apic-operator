
resource local_file write_outputs {
  filename = "gitops-output.json"

  content = jsonencode({
    name        = module.apic.name
    branch      = module.apic.branch
    namespace   = module.apic.namespace
    server_name = module.apic.server_name
    layer       = module.apic.layer
    layer_dir   = module.apic.layer == "infrastructure" ? "1-infrastructure" : (module.apic.layer == "services" ? "2-services" : "3-applications")
    type        = module.apic.type
  })
}