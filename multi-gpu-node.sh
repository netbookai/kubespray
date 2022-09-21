sudo apt-get update
sudo apt install python3-pip -y
git clone https://github.com/netbookai/kubespray.git -b nvidia-gpu-support
cd ~/kubespray/
pip3 install -r requirements.txt
sudo apt-get -y install ansible
cp -rfp ~/kubespray/inventory/sample ~/kubespray/inventory/mycluster
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root pre.yaml
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root post.yaml
mkdir ~/.kube
sudo cat /etc/kubernetes/admin.conf > ~/.kube/config
kubectl create ns netbook
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3    && chmod 700 get_helm.sh    && ./get_helm.sh
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin    && helm repo update
helm install --generate-name nvdp/nvidia-device-plugin -n netbook
watch kubectl get po -A