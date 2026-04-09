#!/bin/bash
Part A: 

1.  lscpu | grep Virtualization
    lsmod | grep kvm
    ls -l /dev/kvm

2. qemu-img create -f qcow2 nova-prime.qcow2 12G
   qemu-img info nova-prime.qcow2

3. sudo ip link add name br-horizon type bridge
   sudo ip link set br-horizon up
   sudo ip addr add 10.0.0.1/24 dev br-horizon
   ip link show br-horizon
   bridge link show

4. sudo ip tuntap add tap0 mode tap user $USER
   sudo ip link set tap0 up
   sudo ip link set tap0 master br-horizon

   qemu-system-x86_64 \
	-enable-kvm \
	-m 768 \
	-drive file=nova-prime.qcow2, format=qcow2 \
	-cdrom alpine-virt-3.20.0-x86_64.iso \
	-boot d \ 
	-netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
	-device e1000,netdev=net0 \
	-nographic

5. sudo lxc-create -n pulse-prime -t -- --dist alpine --release 3.20 --arch amd64
   sudo lxc-start -n pulse-prime
   sudo lxc-ls --fancy
   sudo lxc-attach -n pulse-prime
	

6. sudo lxc-attach ip addr add 10.0.0.2/24 eth0
   sudo ip link set eth0 up 
   
      qemu-system-x86_64 \
	-enable-kvm \
	-m 768 \
	-drive file=nova-prime.qcow2, format=qcow2 \
	-cdrom alpine-virt-3.20.0-x86_64.iso \
	-boot d \ 
	-netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
	-device e1000,netdev=net0 \
	-nographic

    sudo ip addr add 10.0.0.3/24 eth0
    sudo ip link set eth0 up
    sudo lxc-attach -n pulse-prime ping 10.0.0.3
  
Part B:

1. sudo virt-install --name orion-secundus --ram 1024 --vcpus 1 --disk path=/var/lib/libvirt/images/orion-secundus.qcow2,size=15,format=qcow2 --os-type linux --os-variant ubuntu22.04 --network network=default,model=virtio --graphics vnc --cdrom /var/lib/libvirt/boot/ubuntu.iso

2.sudo lxc-create -n beam-secundus -t download \-- -d ubuntu -r focal -a amd64
  sudo lxc-start -n beam-secundus
  sudo lxc-attach -n beam-secundus

3.virsh snapshot-create-as orion-secundus snap1
  virt-clone --original orion-secundus --name orion-clone --auto-clone

4.sudo lxc-cgroup -n beam-secundus memory.limit_in_bytes 1536M
  free -m

Part C:

1. bridge link

2. ping 10.0.0.3
   sudo tcpdump -i br-horizon icmp
   ip netns add ns_test1
   ip netns add ns_test2
   ip netns list

   ip link add veth1 type veth peer name veth2

   ip link set veth1 netns ns_test1
   ip link set veth2 netns ns_test2

   ip netns exec ns_test1 ip addr add 192.168.1.1/24 dev veth1
   ip netns exec ns_test2 ip addr add 192.168.1.2/24 dev veth2

   ip netns exec ns_test1 ip link set veth1 up
   ip netns exec ns_test2 ip link set veth2 up

   ip netns exec ns_test1 ping 192.168.1.2


	 
