#!/bin/bash
# 更新系统并安装必要工具
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# 安装 Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# 将当前用户添加到 docker 组
usermod -aG docker ubuntu

# 启动 Docker 服务
systemctl enable docker
systemctl start docker

# 创建 Jenkins 数据目录
mkdir -p /var/jenkins_home
chown -R 1000:1000 /var/jenkins_home

# 运行 Jenkins 容器
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  jenkins/jenkins:lts

# 等待容器启动并获取初始管理员密码
sleep 30
echo "Jenkins initial admin password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword