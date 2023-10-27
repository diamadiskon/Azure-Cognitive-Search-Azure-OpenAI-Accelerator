RESOURCES FOR PRIVATIZATION

1. **Azure Search Service**: You can configure the name, pricing tier, replica count, partition count, hosting mode, and more for your Azure Search service.

2. **Cognitive Service**: This resource deploys a Microsoft Cognitive Services account with customizable properties.

3. **SQL Server and Database**: You are creating an Azure SQL Server instance and a SQL Database with administrator login and password.

4. **Cosmos DB**: This resource provisions a Cosmos DB account with specific settings like location, offer type, and capabilities.

5. **Bing Search API**: A Bing Search API account is created with a specified SKU and kind.

6. **Form Recognizer**: This resource sets up a Form Recognizer service with a given SKU and name.

7. **Blob Storage Account**: A Blob Storage account is created with the chosen location and SKU.

8. **App Service Plan**: This resource creates a Linux-based App Service Plan with the specified SKU.

9. **Web App**: A web app is created within the App Service Plan. It includes app settings for various configurations, including integration with your bot service, Azure Search, and Azure OpenAI.

Azuredeploy.bicep in the root directory of this repository contains the code for the deployment of the above resources except for the Web App. The Web App is deployed using the bicep files in app/backend directory and app/frontend directory.
