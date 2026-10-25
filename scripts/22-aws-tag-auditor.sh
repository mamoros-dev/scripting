#!/bin/bash

# Escanea recursos EC2 sin etiquetas obligatorias (Owner).
aws ec2 describe-instances --query "Reservations[*].Instances[?not_null(Tags) == `false`].[InstanceId]" --output text