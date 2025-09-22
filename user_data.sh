#!/bin/bash
# update the ubuntu system and install tools
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common jq

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# add current user to docker group
usermod -aG docker ubuntu

# start docker service
systemctl enable docker
systemctl start docker

# create jenkins data directory
mkdir -p /var/jenkins_home
chown -R 1000:1000 /var/jenkins_home

# obtain the public dns of instance 
INSTANCE_PUBLIC_DNS=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
# or use the instance id 
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# run jenkins container
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

# wait for the start of the container
echo "wait for the start of the container..."
sleep 60

# initial admin password
JENKINS_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "正在等待密码文件生成...")

# wait for the password written to log
if [ "$JENKINS_PASSWORD" = "wait for the password written to log..." ]; then
    echo "wait for the password written to log"
    sleep 30
    JENKINS_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
fi

echo "Jenkins initial admin password:"
echo "$JENKINS_PASSWORD"

# wait for the jenkins service
while ! curl -s http://localhost:8080/login > /dev/null; do
    echo "waiting for the jenkins service starting..."
    sleep 10
done

# make jenkins to support alb
docker exec jenkins bash -c 'cat > /var/jenkins_home/init.groovy.d/alb-config.groovy << EOF
import jenkins.model.Jenkins
import hudson.model.User
import hudson.security.csrf.DefaultCrumbIssuer

// waiting for jenkins initialing
Thread.start {
    sleep(10000)
    
    def instance = Jenkins.getInstance()
    
    // 
    def publicDns = "'$INSTANCE_PUBLIC_DNS'".trim()
    if (publicDns && !publicDns.contains("null")) {
        instance.setRootUrl("http://" + publicDns)
        println("设置 Jenkins rootUrl 为: http://" + publicDns)
    }
    
    // configure CSRF for reverse proxy 
    if (instance.getCrumbIssuer() == null) {
        instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
        println("CSRF done")
    }
    
    instance.save()
    println("Jenkins ALB finished configuration")
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
echo "password has been saved to: /root/jenkins_initial_password.txt"