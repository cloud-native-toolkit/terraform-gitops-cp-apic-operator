
resource local_file write_outputs {
  filename = "gitops-output.json"

  content = jsonencode({
    name        = module.apic-operator.name
    branch      = module.apic-operator.branch
    namespace   = module.apic-operator.namespace
    server_name = module.apic-operator.server_name
    layer       = module.apic-operator.layer
    layer_dir   = module.apic-operator.layer == "infrastructure" ? "1-infrastructure" : (module.apic-operator.layer == "services" ? "2-services" : "3-applications")
    type        = module.apic-operator.type
  })
}

resource local_file write_bin_dir {
  filename = ".bin_dir"

  content = module.apic-operator.bin_dir
}