az group create `
  --name rg-dev-lz-portfolio `
  --location canadacentral

az deployment group create `
  --resource-group rg-dev-lz-portfolio `
  --template-file bicep/main.bicep `
  --parameters @bicep/parameters/dev.json
