#!/bin/bash
# 更新系统并安装必要工具
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common jq

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

# 获取实例的公有DNS名称（用于ALB访问）
INSTANCE_PUBLIC_DNS=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
# 或者使用实例ID作为临时标识
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# 运行 Jenkins 容器，配置ALB反向代理支持
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e JAVA_OPTS="-Djenkins.model.Jenkins.rootUrl=http://$INSTANCE_PUBLIC_DNS" \
  -e JENKINS_OPTS="--httpListenAddress=0.0.0.0" \
  --restart unless-stopped \
  jenkins/jenkins:lts

# 等待容器启动
echo "等待 Jenkins 容器启动..."
sleep 60

# 获取初始管理员密码
JENKINS_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "正在等待密码文件生成...")

# 如果密码文件还未生成，等待并重试
if [ "$JENKINS_PASSWORD" = "正在等待密码文件生成..." ]; then
    echo "等待密码文件生成..."
    sleep 30
    JENKINS_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
fi

echo "Jenkins initial admin password:"
echo "$JENKINS_PASSWORD"

# 配置 Jenkins 以支持 ALB 反向代理
echo "配置 Jenkins 支持 ALB 反向代理..."

# wait for the jenkins service
while ! curl -s http://localhost:8080/login > /dev/null; do
    echo "等待 Jenkins Web 服务启动..."
    sleep 10
done

# make jenkins to support alb
docker exec jenkins bash -c 'cat > /var/jenkins_home/init.groovy.d/alb-config.groovy << EOF
import jenkins.model.Jenkins
import hudson.model.User
import hudson.security.csrf.DefaultCrumbIssuer

// 等待 Jenkins 完全初始化
Thread.start {
    sleep(10000)
    
    def instance = Jenkins.getInstance()
    
    // 设置 rootUrl 为 ALB 的地址
    def publicDns = "'$INSTANCE_PUBLIC_DNS'".trim()
    if (publicDns && !publicDns.contains("null")) {
        instance.setRootUrl("http://" + publicDns)
        println("设置 Jenkins rootUrl 为: http://" + publicDns)
    }
    
    // 配置 CSRF 以支持反向代理
    if (instance.getCrumbIssuer() == null) {
        instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
        println("已启用 CSRF 保护")
    }
    
    instance.save()
    println("Jenkins ALB 配置完成")
}
EOF'

# restart the jenkins container
docker restart jenkins

echo "wait Jenkins restarting..."
sleep 30

# for the alb update
cat > /usr/local/bin/update-jenkins-alb-config << 'EOF'
#!/bin/bash
# To get the current ALB DNS
ALB_DNS="$1"
if [ -z "$ALB_DNS" ]; then
    ALB_DNS=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
fi

# update Jenkins configuration
docker exec jenkins bash -c "cat > /var/jenkins_home/update-alb-url.groovy << 'EOS'
import jenkins.model.Jenkins

def instance = Jenkins.getInstance()
instance.setRootUrl('http://$ALB_DNS')
instance.save()
println('Updated Jenkins rootUrl to: http://$ALB_DNS')
EOS"

docker restart jenkins
echo "Jenkins ALB configuration updated"
EOF

chmod +x /usr/local/bin/update-jenkins-alb-config

# output the jenkins info
echo "=============================================="
echo "Jenkins installation finished！"
echo "admin password: $JENKINS_PASSWORD"
echo "local access: http://localhost:8080"
echo "ALB access: http://$INSTANCE_PUBLIC_DNS"
echo "=============================================="

# save the password for a backup
echo "$JENKINS_PASSWORD" > /root/jenkins_initial_password.txt
echo "密码已保存到 /root/jenkins_initial_password.txt"