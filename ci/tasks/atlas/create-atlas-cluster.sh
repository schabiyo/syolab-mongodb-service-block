#!/bin/bash
set -e -x


source source-code/ci/tasks/atlas/create-atlas-project.sh


createProject $ATLAS_USERNAME $ATLAS_API_KEY $ATLAS_PROJECT_NAME projectId

CURL_COMMAND="curl -u 'ATLAS_USERNAME:ATLAS_API_KEY' --digest -H 'Content-Type: application/json' -X POST 'https://cloud.mongodb.com/api/atlas/v1.0/groups/ATLAS_PROJECT_ID/clusters' --data '
{
  'name; : 'MongoCQRS',
  'diskSizeGB' : 160,
  'numShards' : 1,
  'providerSettings' : {
    'providerName' : 'AWS',
    'diskIOPS' : 480,
    'encryptEBSVolume' : false,
    'instanceSizeName' : 'M10',
    'regionName' : 'US_EAST_1'
  },
  'replicationFactor' : 3,
  'replicationSpec':{'US_EAST_1':{'electableNodes':3,'priority':7,'readOnlyNodes':0}},
  'backupEnabled' : false,
  'autoScaling':{'diskGBEnabled':true}
}'"

NEW_CURL_COMMAND=$(sed  "s@ATLAS_API_KEY@${ATLAS_API_KEY}@g" <<< $CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s@ATLAS_PROJECT_ID@${projectId}@g" <<< $NEW_CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s~ATLAS_USERNAME~${ATLAS_USERNAME}~g" <<< $NEW_CURL_COMMAND)
