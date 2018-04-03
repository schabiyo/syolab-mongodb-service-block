#!/bin/bash
#
## @file                get-cluster.sh
## @author              Sani Chabi Yo
## @section DESCRIPTION A script which get information on an Atlas cluster


# gloabal variables
getCluster(){
  CURL_COMMAND="-u 'ATLAS_USERNAME:ATLAS_API_KEY' --digest -H 'Content-Type: application/json' -X GET 'https://cloud.mongodb.com/api/atlas/v1.0/groups/GROUP-ID/clusters/CLUSTER-NAME'"
  # local variable x and y with passed args
  local username=$1
  local api_key=$2
  local group_id=$3
  local cluster_name=$4
  local status=$5

  NEW_CURL_COMMAND=$(sed  "s@ATLAS_API_KEY@${api_key}@g" <<< $CURL_COMMAND)
  NEW_CURL_COMMAND=$(sed  "s@GROUP-ID@${group_id}@g" <<< $NEW_CURL_COMMAND)
  NEW_CURL_COMMAND=$(sed  "s@CLUSTER-NAME@${cluster_name}@g" <<< $NEW_CURL_COMMAND)
  NEW_CURL_COMMAND=$(sed  "s~ATLAS_USERNAME~${username}~g" <<< $NEW_CURL_COMMAND)

  result=$(eval curl $NEW_CURL_COMMAND)
  if [[ $result == *"error"* ]]; then
     echo $result
     exit 1
  else
      access_token=$(jq .stateName <<< $result)
      TRIMMED_RESULT="${access_token%\"}"
      TRIMMED_RESULT="${TRIMMED_RESULT#\"}"
      eval $status="'$TRIMMED_RESULT'"
  fi
}
