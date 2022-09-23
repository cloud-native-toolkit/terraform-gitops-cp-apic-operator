module "dev_software_olm" {
    source = "github.com/ibm-garage-cloud/terraform-software-olm.git"

    cluster_config_file = module.dev_cluster.config_file_path
    cluster_version = ""
    cluster_type = "ocp4"
    olm_version = "0.15.1"
}