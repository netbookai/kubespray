sudo apt-get update
sudo apt-get install linux-headers-$(uname -r)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-drivers
sudo apt install python3-pip -y
git clone https://github.com/netbookai/kubespray.git -b nvidia-gpu-support
cd ~/kubespray/
pip3 install -r requirements.txt
sudo apt-get -y install ansible
cp -rfp ~/kubespray/inventory/sample ~/kubespray/inventory/mycluster
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-docker2
cp ~/kubespray/daemon.json /tmp/daemon.json
sudo cp /tmp/daemon.json /etc/docker/daemon.json
sudo systemctl restart docker
sudo docker run --rm --gpus all nvidia/cuda:11.7.1-base-ubuntu20.04 nvidia-smi
mkdir ~/.kube
sudo cat /etc/kubernetes/admin.conf > ~/.kube/config
kubectl create ns netbook
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3    && chmod 700 get_helm.sh    && ./get_helm.sh
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin    && helm repo update
helm install --generate-name nvdp/nvidia-device-plugin -n netbook
watch kubectl get po -A