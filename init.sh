#!/bin/bash

# Start the postgres server
sysctl -w kernel.shmmax=714219520
/postgres.sh &

# Start Atlassian Jira in the forground
/opt/atlassian/jira/bin/start-jira.sh -fg
