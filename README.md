# aws-eks-cluster-karpenter
DevOps Tutorials

# To get the login password of jenkins
<p>run this command </p>
docker exec <jenkins_container_name> cat /var/jenkins_home/secrets/initialAdminPassword

<p><or container id></p>
docker exec $(docker ps -qf "name=jenkins") cat /var/jenkins_home/secrets/initialAdminPassword

<p> something like this:</p>
ubuntu@ip-172-20-101-203:~$ docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
b4e74c3d7d35417096b1f2125ce99205

<p> To recover your git repo the previous sucess job hash</p>

<p>pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra %</p> git checkout -b previous-successful-build edc86f7
<p>Switched to a new branch 'previous-successful-build'</p>
<p>pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra %</p> git checkout previous-successful-build
<p>Already on 'previous-successful-build'</p>
<p>pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra %</p> git branch
 <p> main</p>
<p>* previous-successful-build</p>
<p>pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra %</p> git branch -D main
<p>Deleted branch main (was 468e01e).</p>
<p>pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra %</p> git branch -m previous-successful-build main
<p>pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra %</p> git branch
<p>* main</p>
<p>pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra %</p> git push origin main --force
<p>Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)</p>
remote: This repository moved. Please use the new location:
remote:   https://github.com/pengchao2022/aws-jenkins-infra.git
To https://github.com/pengchao2022/aws-eks-cluster-karpenter.git
 + 468e01e...edc86f7 main -> main (forced update)