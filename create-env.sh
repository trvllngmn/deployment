#!/usr/bin/env bash

set -eu

ENV=$1
SG=${ENV}-sg
USER_DATA_FILE=user-data.yaml

aws ec2 create-security-group --group-name "$SG" --description "security group for $ENV" > /dev/null
aws ec2 authorize-security-group-ingress --group-name "$SG" --protocol tcp --port 22 --cidr 80.194.77.90/32
aws ec2 authorize-security-group-ingress --group-name "$SG" --protocol tcp --port 22 --cidr 80.194.77.100/32

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-a10897d6 \
    --count 1 \
    --instance-type t2.micro \
    --user-data "$(base64 "$USER_DATA_FILE")" \
    --security-groups "$SG" \
    --query 'Instances[0].InstanceId' \
    | tr -d '"')

# the instance won't immediately exist; this retry loop keeps trying
# until we get the public ip or we've tried 5 times.
PUBLIC_IP=
tries=0
until [ $tries -ge 5 ]; do
    sleep 5
    echo -n .
    PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids "${INSTANCE_ID}" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        | tr -d '"')
    [ -n "$PUBLIC_IP" ] && break
    tries=$[$tries+1]
done

# The `Name` tag is special and shows up as the instance name column
# in the ec2 console
aws ec2 create-tags --resources "$INSTANCE_ID" --tags "Key=Name,Value=${ENV}"

echo "Instance launched at ${PUBLIC_IP}"
