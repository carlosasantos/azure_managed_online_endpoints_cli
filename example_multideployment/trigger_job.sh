run_id_blue=$(az ml job create -f train_job_blue.yml --query name -o tsv)
if [[ -z "$run_id_blue" ]]
then
    echo "Job creation failed"
    exit 3
fi
# az ml job show -n $run_id_blue --web
status=$(az ml job show -n $run_id_blue --query status -o tsv)
if [[ -z "$status" ]]
then
    echo "Status query failed"
    exit 4
fi
running=("NotStarted" "Queued" "Starting" "Preparing" "Running" "Finalizing" "CancelRequested")
while [[ ${running[*]} =~ $status ]]
do
    sleep 5 
    status=$(az ml job show -n $run_id_blue --query status -o tsv)
    echo $status
done
if [[ "$status" != "Completed" ]]  
then
    echo "Training Job failed or canceled"
    exit 3
fi

run_id_green=$(az ml job create -f train_job_green.yml --query name -o tsv)
if [[ -z "$run_id_green" ]]
then
    echo "Job creation failed"
    exit 3
fi
# az ml job show -n $run_id_green --web
status=$(az ml job show -n $run_id_green --query status -o tsv)
if [[ -z "$status" ]]
then
    echo "Status query failed"
    exit 4
fi
running=("NotStarted" "Queued" "Starting" "Preparing" "Running" "Finalizing" "CancelRequested")
while [[ ${running[*]} =~ $status ]]
do
    sleep 5 
    status=$(az ml job show -n $run_id_green --query status -o tsv)
    echo $status
done
if [[ "$status" != "Completed" ]]  
then
    echo "Training Job failed or canceled"
    exit 3
fi


# az ml model create --name iris_model --version 1 --path azureml://jobs/blue_soursop_03436wnjmg/outputs/artifacts/paths/model/ --resource-group my-resource-group --workspace-name my-workspace

az ml model create --name "iris-model-blue" \
                   --type "mlflow_model" \
                   --path "azureml://jobs/$run_id_blue/outputs/artifacts/model"

az ml model create --name "iris-model-green" \
                   --type "mlflow_model" \
                   --path "azureml://jobs/$run_id_green/outputs/artifacts/model"

# az ml model create --name "mir-sample-sklearn-mlflow-model" \
                #    --type "mlflow_model" \
                #    --path "sklearn-diabetes/model"

az ml online-endpoint create -f endpoint.yml

az ml online-deployment create -f deployment_blue.yml
az ml online-deployment create -f deployment_green.yml

az ml online-endpoint update --name iris-endpoint-2424512-bluegreen  --traffic "iris-deployment-green=50 iris-deployment-blue=50"
