#install python with required modules
python -m ensurepip --upgrade
python -m pip install --upgrade pip setuptools

#connect to azure environment
az login

#install Azure extensions
 az extension add -n ml -y
az extension update -n ml


#Clone GitHub repo on lab vm
git clone https://github.com/MicrosoftLearning/mslearn-azure-ml.git azure-ml-labs
#Change directory to azure-ml-labs/Labs/05
cd azure-ml-labs/Labs/05

# Generate a random string (UUID without dashes, first 18 chars)
$guid = [guid]::NewGuid().ToString()
$suffix = ($guid -replace '-', '').Substring(0,18)

# Set the necessary variables
$RESOURCE_GROUP = "rg-dp100-l$suffix"
$RESOURCE_PROVIDER = "Microsoft.MachineLearningServices"
$REGIONS = @("eastus", "westus", "centralus", "northeurope", "westeurope")

# Select a random region
$RANDOM_REGION = Get-Random -InputObject $REGIONS

$WORKSPACE_NAME = "mlw-dp100-l$suffix"
$COMPUTE_CLUSTER = "aml-cluster"

Write-Host "Register the Machine Learning resource provider:"
az provider register --namespace $RESOURCE_PROVIDER

Write-Host "Create a resource group and set as default:"
az group create --name $RESOURCE_GROUP --location $RANDOM_REGION | Out-Null
az configure --defaults group=$RESOURCE_GROUP

Write-Host "Create an Azure Machine Learning workspace:"
az ml workspace create --name $WORKSPACE_NAME | Out-Null
az configure --defaults workspace=$WORKSPACE_NAME

Write-Host "Creating a compute cluster with name: $COMPUTE_CLUSTER"
az ml compute create --name $COMPUTE_CLUSTER --size STANDARD_DS11_V2 --max-instances 2 --type AmlCompute

Write-Host "Creating a data asset with name: diabetes-folder"
az ml data create --name diabetes-folder --path ./data

Write-Host "Creating components"
az ml component create --file ./fix-missing-data.yml
az ml component create --file ./normalize-data.yml
az ml component create --file ./train-decision-tree.yml
az ml component create --file ./train-logistic-regression.yml
