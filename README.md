# aws-eks-cluster-karpenter
DevOps Tutorials

# To get the login password of jenkins
<p>run this command </p>
docker exec <jenkins_container_name> cat /var/jenkins_home/secrets/initialAdminPassword

<p>or container id</p>
docker exec $(docker ps -qf "name=jenkins") cat /var/jenkins_home/secrets/initialAdminPassword

<p> something like this:</p>
ubuntu@ip-172-20-101-203:~$ docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
b4e74c3d7d35417096b1f2125ce99205