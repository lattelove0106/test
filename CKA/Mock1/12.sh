#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# 1. 네임스페이스 생성
kubectl create ns mariadb --dry-run=client -o yaml | kubectl apply -f -

# 2. 제공된 YAML로 PersistentVolume 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-mariadb
  labels:
    app: mariadb
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: "" 
  hostPath:
    path: /mnt/data/mariadb
EOF

# 3. 수정 전 Deployment 파일 생성 (사용자가 편집할 파일: maria_deploy.yaml)
cat <<EOF > maria_deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: maria-deployment
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: maria-deployment
  template:
    metadata:
      labels:
        app: maria-deployment
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.6
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpass
        volumeMounts:
        - name: mariadb-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-storage
        persistentVolumeClaim:
          claimName: MariaDB
EOF

echo -e "${GREEN}환경 구축 및 'maria_deploy.yaml' 파일 생성이 완료되었습니다.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: #12 PVC"
echo -e "A Persistent Volume (pv-mariadb) already exists and is retained for reuse."
echo ""
echo -e "Tasks:"
echo -e "1. Create a PersistentVolumeClaim named 'MariaDB' in the 'mariadb' namespace as follows:"
echo -e "   - Access mode: ReadWriteOnce"
echo -e "   - Storage capacity: 250Mi"
echo -e "2. Edit the maria-deployment in the file located at 'maria_deploy.yaml' to use the newly created PVC."
echo -e "3. Verify that the deployment is running and is stable."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
