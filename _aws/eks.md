# EKS

## IAM Roles for Service Accounts (IRSA)

[Documentation](https://eksctl.io/usage/iamserviceaccounts/)

Amazon EKS supports IRSA - which allows clusters operators to map IAM Roles to Kubernetes Service Accounts.

This helps control access to other AWS tools, such as S3.

This works with IAM OpenID Connect Provider (OIDC) that EKS exposes. [OIDC](https://openid.net/connect/) is an identity layer on top of the OAuth 2.0 protocol, that verifies the identity of the End-User based on the authentication performed by the Authentication Server.

In EKS, there is an admission controller that injects AWS session credentials into pods based on the annotations on the Service Account used by the pod.

> Just because EKS has a OIDC Provider URL does not mean that an existing identity provider exists! Check "Identity Providers" under IAM to see if there exists one. Most like you'll need to create one : `eksctl utils associate-iam-oidc-provider --cluster <cluster_name> --approve`

> In `eksctl`, the IAM Role and Service Accounts are represented by a resource `iamserviceaccount`.

> Why does EKS have its own auth config map for permissioning? Why not have permission in IAM roles?
>
> This is for permission model inside Kubernetes, to allow AWS permission inside of it. (So not permission on a pod level, but on a Kubernetes user level).

## Identity and Access Management

1. Service-linked Role - `AWSServiceRoleForAmazonEKS`
1. Service-linked Role (Node Groups) - `AWSServiceRoleForAmazonEKSNodegroup`
1. Cluster IAM Role
1. Node IAM Role
1. Pod execution IAM Role
1. Service Account (Kubernetes) IAM Role (IRSA)