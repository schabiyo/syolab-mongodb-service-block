#!/bin/bash
set -e -x


source syolab-mongodb-cqrs/ci/tasks/atlas/create-atlas-project.sh


createProject $ATLAS_API_KEY $ATLAS_PROJECT_NAME projectId
