#!/bin/bash
#!/bin/bash

FIRST_MASTER=false
MASTER_NODE=''

VALID_ARGS=$(getopt -o t:fn: --long k3s-token:,first-master,master-node: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -t | --k3s-token)
        K3S_TOKEN=$2
        shift 2
        ;;
    -f | --first-master)
        FIRST_MASTER=true
        shift
        ;;
    -n | --master-node)
        MASTER_NODE=$2
        shift 2
        ;;
    --) shift; 
        break 
        ;;
  esac
done

if $FIRST_MASTER
then
  curl -sfL https://get.k3s.io | sh -s - server \
			--disable-cloud-controller \
			--disable metrics-server \
			--write-kubeconfig-mode=644 \
			--disable local-storage \
			--node-name="$(hostname -f)" \
			--cluster-cidr="10.244.0.0/16" \
			--kube-controller-manager-arg="bind-address=0.0.0.0" \
			--kube-proxy-arg="metrics-bind-address=0.0.0.0" \
			--kube-scheduler-arg="bind-address=0.0.0.0" \
			--kubelet-arg="cloud-provider=external" \
			--token="$K3S_TOKEN" \
			--tls-san="$(hostname -I | awk '{print $1}')" \
			--flannel-iface=ens10
else 
  curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN sh -s - server \
      --server https://$MASTER_NODE:6443 \
      --cluster-cidr="10.244.0.0/16 \
      --disable-cloud-controller

fi
