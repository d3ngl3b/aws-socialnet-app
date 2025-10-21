<a name="top"></a>
[![CN_Header](https://social-network-documentation.s3.us-east-1.amazonaws.com/SN_HEADER.png)](https://social-network-documentation.s3.us-east-1.amazonaws.com/SN_HEADER.png)
[![Python](https://img.shields.io/badge/Python-FFD43B?style=for-the-badge&logo=python&logoColor=blue)]()
[![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=green)]()
[![AWS](https://img.shields.io/badge/Amazon_Web_Services-FF9900?style=for-the-badge&logo=amazonwebservices&logoColor=white)]()
[![Kubernetes](https://img.shields.io/badge/Kubernetes-3069DE?style=for-the-badge&logo=kubernetes&logoColor=white)]()
[![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)]()
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)]()
[![ArgoCD](https://img.shields.io/badge/Argo%20CD-1e0b3e?style=for-the-badge&logo=argo&logoColor=#d16044)]()
[![Bash](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)]()



## Table of Contents
- [About](#-about)
- [What's New](#-whats-new)
- [AWS resources](#-aws-resources)
- [K8s cluster](#-kubernetes-cluster)
- [ArgoCD](#argocd-deployment)
- [Contacts](#-contacts)

## 🚀 About

This project is a **social network Blog application** built with **Django**, featuring all the core capabilities of a modern social platform.

### Main Features
- Create posts with images and comments  
- Customize personal profiles  
- Subscribe to other users’ updates  
- Share posts via email  
- Search for posts by tags or content  

### Technologies Used
- **Backend:** Django with PostgreSQL (full-text search support)  
- **Media Storage:** AWS S3 bucket for image uploads paired with AWS Lambda image resizer  
- **Email Service:** AWS SES (Simple Email Service)  
- **Hosting:** Custom AWS EC2 Kubernetes cluster  
- **Domain & Routing:** AWS Route 53  
- **Security:** AWS Application Load Balancer with HTTPS via AWS Certificate Manager (ACM), AWS Security Groups allowing Calico network traffic  

This setup provides a seamless, secure, and scalable social blogging experience, leveraging AWS infrastructure for reliable storage, email delivery, and cloud deployment.

[![App example](https://social-network-documentation.s3.us-east-1.amazonaws.com/MainExample.png)]()
*Figure 1: Example of the app interface.*

## ✨ What's New

### Version 1.6.0 (Latest)

This section will be regularly updated as new features and improvements are added to the project.  
Future updates may include additional functionality, performance enhancements, and UI refinements.  
Check back here for the latest changes and development progress.
> **Migration Note**: This is the first verstion released.

## ☁️ AWS resources

This diagram provides a simplified overview of the AWS infrastructure and system architecture used in the application.

[![AWS_map](https://social-network-documentation.s3.us-east-1.amazonaws.com/Social-Network-AWS-resources.png)]()
*Figure 2: AWS resources diagram.*

## 📝 Kubernetes Cluster

To build the k8s cluster, following steps were made:

```shell
### update hostname
sudo hostnamectl set-hostname controlplane
sudo hostnamectl set-hostname worker1
sudo hostnamectl set-hostname worker2

### check mac and uuid
ip link
cat /sys/class/dmi/id/product_uuid

### turn swap off
swapoff -a

### enable ip packet forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/k8s.conf
sysctl --system
sysctl net.ipv4.ip_forward

### install containerd
apt update && sudo apt upgrade -y
apt-get install containerd
ctr --version

### Install cni plugins
mkdir -p /opt/cni/bin
wget https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.7.1.tgz

### configure containerd
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
head /etc/containerd/config.toml

### Modify configuration file
nano /etc/containerd/config.toml # enable SystemdCgroup = true
systemctl restart containerd

### configure the systemd cgroup driver
vi /etc/containerd/config.toml

Within [plugins.”io.containerd.grpc.v1.cri”.containerd.runtimes.runc.options] section
SystemdCgroup = true
systemctl restart containerd

### Add Kubernetes repos and install tools
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm
apt-mark hold kubelet kubeadm

### Install kubectl on controlplane

apt-get install -y kubectl


### Intialize Cluster
kubeadm init --pod-network-cidr=192.168.0.0/16

### Configure a regular user for kubectl (un sudo)

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

### Install network plugin - calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml
watch kubectl get pods -n calico-system

### Finishing steps
sudo cat /etc/kubernetes/admin.conf # Copy content

### On all nodes
KUBELET_EXTRA_ARGS=--cloud-provider=external
sudo systemctl daemon-reload
sudo systemctl restart kubelet

### On control plane
## Under first role
- --cloud-provider=external
nano /etc/kubernetes/manifests/kube-controller-manager.yaml

### Under first role
- --cloud-provider=external
nano /etc/kubernetes/manifests/kube-apiserver.yaml

### Install aws controller
kubectl apply -k "github.com/kubernetes/cloud-provider-aws/examples/existing-cluster/base/?ref=master"

### Modiby demon set with proper cluster name (under args in file)
kubectl edit daemonset aws-cloud-controller-manager -n kube-system
- --cluster-name=<name>
- --allocate-node-cidrs=false
- --cluster-cidr=192.168.0.0/16 

### In AWS add proper tags
Key: kubernetes.io/cluster/<cluster-name>
Value: owned

### Patch Porvider ids for worker nodes
kubectl patch node <node name> -p '{"spec":{"providerID":"aws:///<Region>/<EC2ID>"}}'

### Fix calico for matching CIDR block
kubectl patch installation default \
  --type='merge' \
  -p '{"spec":{"calicoNetwork":{"ipPools":[{"cidr":"192.168.0.0/16","encapsulation":"VXLAN","natOutgoing":"Enabled","nodeSelector":"all()"}]}}}'

```
## 🐙 ArgoCD Deployment 

### ArgoCD Deployment

ArgoCD allows to version control entire infrastructure by tracking [Gitlab repository](https://gitlab.com/gl3b/social-network-argo-cd/-/tree/main). Following diagram represents the structure of application deployed in k8s cluster. 

[![AWS_map](https://social-network-documentation.s3.us-east-1.amazonaws.com/ArchitectureArgoCD.png)]()
*Figure 3: ArgoCD Architecture.*

[![AWS_map](https://social-network-documentation.s3.us-east-1.amazonaws.com/trafficArgoCD.png)]()
*Figure 4: ArgoCD Traffic.*

## 🗨️ Contacts

- **Email**:  gleb@adenisov.com.
- **LinkedIn**: [link to account.](https://www.linkedin.com/in/gleb-denisov-40b5472a4/)

[Back to top](#top)
