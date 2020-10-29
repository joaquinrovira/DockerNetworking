sudo ip link delete br0 type bridge
sudo iptables -D FORWARD -p all -i br0 -j ACCEPT
sudo ip netns delete h0
sudo ip netns delete h0p0
sudo ip netns delete h0p1
sudo ip netns delete h1
sudo ip netns delete h1p0
sudo ip netns delete h1p1
sudo ip netns delete h2
sudo ip netns delete h2p0
sudo ip netns delete h2p1
sudo ip netns delete h3
sudo ip netns delete h3p0
sudo ip netns delete h3p1
docker stop $(docker container ls -aq) >>/dev/null
