#!/bin/bash

# Cluster configuration
MACHINE_ID=$(hostname)
POD_NETWORK="10.233.0.0/16"
CLUSTER_VERSION="1.22.4-00"

# Add Kubernetes deb repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

# Install kubelet / kubeadm / kubectl from new deb repo
sudo apt install -y kubelet=$CLUSTER_VERSION kubeadm=$CLUSTER_VERSION kubectl=$CLUSTER_VERSION

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system

# Install docker and containerd
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

# Remove cri in containerd disabled_plugins
sudo sed -i 's/"cri"//' /etc/containerd/config.toml
sudo systemctl restart containerd

# Pull container images
sudo systemctl enable kubelet
sudo kubeadm config images pull

# Initialize cluster (Master Node config)
sudo kubeadm init --pod-network-cidr=$POD_NETWORK

# Kubectl configuration
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Being able to deploy PODs on master node
kubectl taint node $MACHINE_ID node-role.kubernetes.io/control-plane:NoSchedule-

# Cluster deployment network
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
curl https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml -O
sed -i "s,192.168.0.0/16,$POD_NETWORK,g" custom-resources.yaml
kubectl create -f custom-resources.yaml
