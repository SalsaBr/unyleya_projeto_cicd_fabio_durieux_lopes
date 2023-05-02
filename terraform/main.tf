# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "unyleya" {
  name     = "unyleya-resources"
  location = "East US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "unynet" {
  name                = "unyleya-network"
  resource_group_name = azurerm_resource_group.unyleya.name
  location            = azurerm_resource_group.unyleya.location
  address_space       = ["10.0.0.0/16"]
}




# Cria o AKS
resource "azurerm_kubernetes_cluster" "unyleya" {
  name                = "unyleya-aks1"
  location            = azurerm_resource_group.unyleya.location
  resource_group_name = azurerm_resource_group.unyleya.name
  dns_prefix          = "unyaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Lab"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.unyleya.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.unyleya.kube_config_raw

  sensitive = true
}

#Cria o ACR
resource "azurerm_container_registry" "unyleya_acr" {
  name                = "unyleyaContainerRegistryAlpha"
  resource_group_name = azurerm_resource_group.unyleya.name
  location            = azurerm_resource_group.unyleya.location
  sku                 = "Premium"
  admin_enabled       = false
  georeplications {
    location                = "East US 2"
    zone_redundancy_enabled = true
    tags                    = {}
  }
  #georeplications {
  #  location                = "North Europe"
  #  zone_redundancy_enabled = true
  #  tags                    = {}
  #}
}