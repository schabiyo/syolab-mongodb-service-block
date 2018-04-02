#!/bin/bash
set -e -x


source source-code/ci/tasks/atlas/create-atlas-project.sh
source source-code/ci/tasks/atlas/get-cluster.sh

createProject $ATLAS_USERNAME $ATLAS_API_KEY $ATLAS_ORG_ID $ATLAS_PROJECT_NAME projectId

CURL_COMMAND="-u 'ATLAS_USERNAME:ATLAS_API_KEY' --digest -H 'Content-Type: application/json' -X POST 'https://cloud.mongodb.com/api/atlas/v1.0/groups/ATLAS_PROJECT_ID/clusters' --data '
{
  \"name\" : \"ATLAS_CLUSTER_NAME\",
  \"diskSizeGB\" : 160,
  \"numShards\" : 1,
  \"providerSettings\" : {
    \"providerName\" : \"AWS\",
    \"diskIOPS\" : 480,
    \"encryptEBSVolume\" : false,
    \"instanceSizeName\" : \"M10\",
    \"regionName\" : \"US_EAST_1\"
  },
  \"replicationFactor\" : 3,
  \"replicationSpec\":{\"US_EAST_1\":{\"electableNodes\":3,\"priority\":7,\"readOnlyNodes\":0}},
  \"backupEnabled\": false,
  \"autoScaling\":{\"diskGBEnabled\":true}
}'"

NEW_CURL_COMMAND=$(sed  "s@ATLAS_API_KEY@${ATLAS_API_KEY}@g" <<< $CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s@ATLAS_PROJECT_ID@${projectId}@g" <<< $NEW_CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s~ATLAS_USERNAME~${ATLAS_USERNAME}~g" <<< $NEW_CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s~ATLAS_CLUSTER_NAME~${ATLAS_CLUSTER_NAME}~g" <<< $NEW_CURL_COMMAND)


result=$(eval curl $NEW_CURL_COMMAND)
  if [[ $result == *"error"* ]]; then
      echo $result
      if [[ $result == *"GROUP_ALREADY_EXISTS"* ]]; then
          echo "Cluster already exist"
          exit 0
      exit 1
  else
       access_token=$(jq .id <<< $result)
       TRIMMED_RESULT="${access_token%\"}"
       TRIMMED_RESULT="${TRIMMED_RESULT#\"}"
       eval $responsevar="'$TRIMMED_RESULT'"
  fi

echo "Waiting until Cluster is successfully created "

#Try for a maximum of 5 minutes
## sleep in bash for loop ##
for i in {1..5}
do
   #Get the cluster Status
   getCluster $ATLAS_USERNAME $ATLAS_API_KEY $projectId $ATLAS_CLUSTER_NAME state
   echo "provisioningState:"$state
   if [[ $state == "IDLE" ]]; then
     portal_url=$(jq .mongoURI <<< $result)
     MESSAGE="Cluster was successully created and can be accessed using the following URL:${portal_url}" ; simple_green_echo
     exit 0
   elif (( $state == "CREATING" )); then
     echo "Waiting..."
     sleep 1m
   else
     #The creation failes for a raison
     echo "==>The cluster provisioning failed for a raison.";
     exit 1
   fi
done

