#!/bin/bash
#
## @file                create-astlas-project.sh
## @author              Sani Chabi Yo
## @section DESCRIPTION A script which create a MongoDB deployment on Atlas


# gloabal variables
createProject(){
  CURL_COMMAND="-u 'ATLAS_USERNAME:ATLAS_API_KEY' --digest -H 'Content-Type: application/json' -X POST 'https://cloud.mongodb.com/api/atlas/v1.0/groups' --data '{ \"name\" : \"ATLAS_PROJECT_NAME\", \"orgId\" : \"ATLAS_ORG_ID\" }'"
  # local variable x and y with passed args
  local username=$1
  local api_key=$2
  local org_id=$3
  local project_name=$4
  local responsevar=$5

  NEW_CURL_COMMAND=$(sed  "s@ATLAS_API_KEY@${api_key}@g" <<< $CURL_COMMAND)
  NEW_CURL_COMMAND=$(sed  "s@ATLAS_ORG_ID@${org_id}@g" <<< $CURL_COMMAND)
  NEW_CURL_COMMAND=$(sed  "s@ATLAS_PROJECT_NAME@${project_name}@g" <<< $NEW_CURL_COMMAND)
  NEW_CURL_COMMAND=$(sed  "s~ATLAS_USERNAME~${username}~g" <<< $NEW_CURL_COMMAND)

  result=$(eval curl $NEW_CURL_COMMAND)
  if [[ $result == *"error"* ]]; then
     echo $result
     exit 1
  else
      access_token=$(jq .id <<< $result)
      TRIMMED_RESULT="${access_token%\"}"
      TRIMMED_RESULT="${TRIMMED_RESULT#\"}"
      eval $responsevar="'$TRIMMED_RESULT'"
  fi
}
