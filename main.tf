terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "kubernetes_pods_not_scheduled_preventing_application_scaling" {
  source    = "./modules/kubernetes_pods_not_scheduled_preventing_application_scaling"

  providers = {
    shoreline = shoreline
  }
}