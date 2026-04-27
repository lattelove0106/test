#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 준비 (Setup) ===${NC}"

# 1. 시뮬레이션을 위한 데비안 패키지 파일 생성
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.9/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb

# 2. 기존 설정 초기화 (실습을 위해 0으로 설정)
sudo sysctl -w net.bridge.bridge-nf-call-iptables=0 &> /dev/null
sudo sysctl -w net.ipv6.conf.all.forwarding=0 &> /dev/null
sudo sysctl -w net.ipv4.ip_forward=0 &> /dev/null

echo -e "${GREEN}환경 준비 완료: ~/cri-dockerd...deb 파일이 생성되었으며 시스템 파라미터가 초기화되었습니다.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question 13) ===${NC}"
echo -e "Tasks:"
echo -e "1. Install the Debian package ~/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb using dpkg."
echo -e "2. Enable and start the cri-docker service."
echo -e "3. Configure these system parameters:"
echo -e "   - Set net.bridge.bridge-nf-call-iptables to 1"
echo -e "   - Set net.ipv6.conf.all.forwarding to 1"
echo -e "   - Set net.ipv4.ip_forward to 1"
echo -e "   - Set net.netfilter.nf_conntrack_max to 131072"
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
