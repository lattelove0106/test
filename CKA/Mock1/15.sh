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
read -p "Press Enter after you complete the tasks to start validation..."

echo -e "\n${BLUE}=== [3] Validation Result ===${NC}"

# 1. Verify Node Taint
TAINT_CHECK=$(kubectl describe node $NODE_NAME | grep -i "Taints:" | grep "IT=Kiddie:NoSchedule")
if [ ! -z "$TAINT_CHECK" ]; then
    echo -e "1. Node Taint (IT=Kiddie:NoSchedule): ${GREEN}PASS${NC}"
else
    echo -e "1. Node Taint (IT=Kiddie:NoSchedule): ${RED}FAIL${NC}"
fi

# 2. Verify Pod Placement with Toleration
# Looking for a pod (excluding system pods) successfully scheduled on node01
SCHEDULED_POD=$(kubectl get pods -A -o wide | grep $NODE_NAME | grep -v "kube-system" | grep "Running")
if [ ! -z "$SCHEDULED_POD" ]; then
    echo -e "2. Pod Placement on $NODE_NAME: ${GREEN}PASS${NC}"
    echo -e "   Found Pod:\n$SCHEDULED_POD"
else
    echo -e "2. Pod Placement on $NODE_NAME: ${RED}FAIL${NC} (Ensure your pod has the correct toleration and is running on node01)"
fi