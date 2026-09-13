#!/bin/bash

set -e

STACK_NAME="patient-management"
ENDPOINT="http://localhost:4566"
TEMPLATE="./cdk.out/localstack.template.json"

echo "========================================"
echo "Deploying CloudFormation stack"
echo "========================================"

if ! aws --endpoint-url="$ENDPOINT" cloudformation deploy \
    --stack-name "$STACK_NAME" \
    --template-file "$TEMPLATE"
then

    echo ""
    echo "========================================"
    echo "STACK DEPLOYMENT FAILED"
    echo "========================================"

    echo ""
    echo "Failed resources:"
    echo "========================================"

    aws --endpoint-url="$ENDPOINT" cloudformation describe-stack-events \
        --stack-name "$STACK_NAME" \
        --query "StackEvents[?contains(ResourceStatus, 'FAILED')].[Timestamp,LogicalResourceId,ResourceType,ResourceStatus,ResourceStatusReason]" \
        --output table || true

    echo ""
    echo "Full CloudFormation events:"
    echo "========================================"

    aws --endpoint-url="$ENDPOINT" cloudformation describe-stack-events \
        --stack-name "$STACK_NAME" \
        --output table || true

    exit 1
fi

echo ""
echo "========================================"
echo "STACK DEPLOYMENT SUCCESSFUL"
echo "========================================"

echo ""
echo "Load Balancer:"
echo "========================================"

aws --endpoint-url="$ENDPOINT" elbv2 describe-load-balancers \
    --query "LoadBalancers[0].DNSName" \
    --output text