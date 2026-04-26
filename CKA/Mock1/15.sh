#!/bin/bash

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] Environment Setup ===${NC}"

# Check if node01 exists
NODE_NAME="node01"
EXISTS=$(kubectl get nodes | grep $NODE_NAME)

if [ -z "$EXISTS" ]; then
    echo -e "${RED}Error: Node '$NODE_NAME' not found.${NC}"
    echo "Current nodes:"
    kubectl get nodes
    exit 1
fi

# Clean up existing taints for a fresh start
kubectl taint nodes $NODE_NAME IT- &> /dev/null

echo -e "${GREEN}Setup Completed: $NODE_NAME is ready for the task.${NC}"
echo ""

echo -e "${BLUE}=== [2] QUESTION: #15 Taints & Tolerations ===${NC}"
echo -e "Task:"
echo -e "1. Add a taint to node01 so that no normal pods can be scheduled in the node."
echo -e "2. Key=IT Value=Kiddie Type=NoSchedule"
echo -e "3. Schedule a Pod on node01 adding the correct toleration to the spec and ensure"
echo -e "   that it lands on the correct node."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
