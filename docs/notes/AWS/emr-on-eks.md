# EMR on EKS

## EMR Getting Permission For EKS

```
eksctl create iamidentitymapping \
    --cluster my_eks_cluster \
    --namespace kubernetes_namespace \
    --service-name "emr-containers"
```

What this does:

1. Create Kubernetes Role - "emr-containers"
1. Create Kubernetes RoleBinding - Role "emr-containers", User "emr-containers"
1. Update `aws-auth` config map to map IAM Role `AWSServiceRoleForAmazonEMRContainers` to User "emr-containers"

> Who creates the User "emr-containers"?
>
> From [K8s doc](https://kubernetes.io/docs/reference/access-authn-authz/authentication/): In this regard, Kubernetes does not have objects which represent normal user accounts. Normal users cannot be added to a cluster through an API call.

## Logging

EMR on EKS uses FluentD for logging. A dedicated container is created, the name of which contains "fluentd" (as of 2021-04-19).