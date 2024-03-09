# CI/CD PIPELINE
This pipeline made use of Github Actions for Continous Integration and ArgoCD for Continuous Deployment

Terraform was used to write the code that created the AWS Elastic Kubrnetes Service, S3 buckets, DynamoDB table and AWS ebs_csi_driver.

For this Pipeline I used github actions to:
- build a docker image with the use of the Dockerfile'
- push the docker image to docker hub'
- automate the creation of the AWS infrastructure using terraform script,
- Install ArgoCD in the cluster
- Install prometheus and grafana using helm


I am deploying a static website gotten from (https://www.free-css.com/free-css-templates).
The `Dockerfile` holds the necessary commands used to build the docker image. 

The `makefile` holds the commands to build the AWS infrastructure and deploy application with argocd if I want to create this without automation.





The major challenge I had with this project was that the prometheus pod and prometheus-alertmanger pod was in a pending state which made it impossible to view the prometheus dashboard on the browser. Below is a step by step process on how I resolved the issue.

# How to troubleshoot a pending pod in kubernetes
1. Filter the pending pod `kubectl get pods -n prometheus --field-selector=status.phase=Pending`

2. Check if the resaon for the pending state is a pod issue or a scheduler issue
We will have to run the command `kubectl describe pods <name of pod> -n <namespace>` to see what could be wrong with the pods.

```
Name:             prometheus-server-7ff484fff5-wjb7t
Namespace:        prometheus
Priority:         0
Service Account:  prometheus-server
Node:             <none>
Labels:           app.kubernetes.io/component=server
                  app.kubernetes.io/instance=prometheus
                  app.kubernetes.io/managed-by=Helm
                  app.kubernetes.io/name=prometheus
                  app.kubernetes.io/part-of=prometheus
                  app.kubernetes.io/version=v2.50.1
                  helm.sh/chart=prometheus-25.15.0
                  pod-template-hash=7ff484fff5
Annotations:      <none>
Status:           Pending

Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  5m7s (x3 over 25m)  default-scheduler  running PreBind plugin "VolumeBinding": binding volumes: context deadline exceeded

```

The prometheus server pods wasn't scheduled to any pods.

```
Name:             prometheus-alertmanager-0
Namespace:        prometheus
Priority:         0
Service Account:  prometheus-alertmanager
Node:             <none>
Labels:           app.kubernetes.io/instance=prometheus
                  app.kubernetes.io/name=alertmanager
                  apps.kubernetes.io/pod-index=0
                  controller-revision-hash=prometheus-alertmanager-5d4997748b
                  statefulset.kubernetes.io/pod-name=prometheus-alertmanager-0
Annotations:      checksum/config: 0b24b67c30ec16e627198687f62d21806cff6abb08903e8652c43c1edf562b45
Status:           Pending


Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  5m7s (x3 over 25m)  default-scheduler  running PreBind plugin "VolumeBinding": binding volumes: context deadline exceeded

```
The prometheus alert manager pod wasn't also scheduled to any nodes

3. I started to research on how to rectify a volume binding error for kubernetes pods.

4.  After troubleshooting, I came across these (https://repost.aws/knowledge-center/eks-persistent-storage) and videos on youtube on how to get this done and I decided to use a terraform script to create the cbs driver. This is the resource in the **ebs-driver directory**


5. Write a claim for your ebs and edit the prometheus pod and alertmanager pods
In these section of the resources above, let the claimName match the nameunder the metadata section in the claim.yml file
```
volumes:
    - name: test-volume
      persistentVolumeClaim:
        claimName: ebs-csi-claim

```




