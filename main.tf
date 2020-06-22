provider "azurerm" {
  features {}
}

provider "null" {
}

resource "azurerm_resource_group" "rg" {
  name      = "TerraformOnAzure-RG"
  location  = "westeurope"
}

resource "azurerm_app_service_plan" "appsvcplan" {
  name                = "TerraformOnAzure-appserviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = "TerraformOnAzure-app-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appsvcplan.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "10.15.2"
    "ApiUrl" = ""
    "ApiUrlShoppingCart" = ""
    "MongoConnectionString" = ""
    "SqlConnectionString" = ""
    "productImagesUrl" = "https://raw.githubusercontent.com/microsoft/TailwindTraders-Backend/master/Deploy/tailwindtraders-images/product-detail"
    "Personalizer__ApiKey" = ""
    "Personalizer__Endpoint" = ""
  }
}

resource "null_resource" "azure-cli" {

  provisioner "local-exec" {
      command = "az webapp deployment source config --branch master --name $webappname --repo-url $repourl --resource-group $resourcegroup"

      environment = {
          webappname = azurerm_app_service.appsvc.name
          resourcegroup = azurerm_resource_group.rg.name
          repourl = "https://github.com/OmegaMadLab/AzureEats-Website"
      }
  }
  depends_on = [azurerm_app_service.appsvc]

}



