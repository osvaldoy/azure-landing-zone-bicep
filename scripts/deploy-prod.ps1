Write-Host "WARNING: Production deployment"
Read-Host "Press ENTER to continue"

az group create `
  --name rg-prod-lz-portfolio `
  --location canadacentral

az deployment group create `
  --resource-group rg-prod-lz-portfolio `
  --template-file bicep/main.bicep `
  --parameters @bicep/parameters/prod.json
