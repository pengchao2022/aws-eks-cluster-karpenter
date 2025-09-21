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

<p> To recover your git repo the previous sucess job hash</p>

pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra % git checkout -b previous-successful-build edc86f7
Switched to a new branch 'previous-successful-build'
pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra % git checkout previous-successful-build
Already on 'previous-successful-build'
pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra % git branch
  main
* previous-successful-build
pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra % git branch -D main
Deleted branch main (was 468e01e).
pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra % git branch -m previous-successful-build main
pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra % git branch
* main
pengchaoma@Pengchaos-MacBook-Pro aws-jenkins-infra % git push origin main --force
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote: This repository moved. Please use the new location:
remote:   https://github.com/pengchao2022/aws-jenkins-infra.git
To https://github.com/pengchao2022/aws-eks-cluster-karpenter.git
 + 468e01e...edc86f7 main -> main (forced update)