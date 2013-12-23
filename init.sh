#!/bin/bash

# Start the postgres server
/postgres.sh &

# Start Atlassian Jira in the forground
/opt/atlassian/jira/bin/start-jira.sh -fg
