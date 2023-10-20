#!/bin/bash
TOPIC=/topic/race-mapper
BROKER_URL=localhost
BROKER_PORT=61613
USERNAME=admin
PASSWORD=admin
FILE=data.csv

python send_to_activemq.py $BROKER_URL $BROKER_PORT $USERNAME $PASSWORD $TOPIC $FILE
