locals {
  name          = "ibm-apic-operator"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  layer = "services"
  type  = "operators"
  application_branch = "main"
  layer_config = var.gitops_config[local.layer]
    values_content = {
      "ibm_apic_operator" = {
        subscriptions = {
          ibmapic = {
            name = "ibm-apiconnect"
            subscription = {
              channel = var.channel
              installPlanApproval = "Automatic"
              name = "ibm-apiconnect"
              source = var.catalog
              sourceNamespace = var.catalog_namespace
            }
          }
        }
      }
  }
  values_file = "values.yaml"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}' '${local.values_file}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
