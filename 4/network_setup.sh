sudo mkdir -p /var/run/netns
docker build -q -t ubuntu-ping .
sudo ip link add br0 type bridge
sudo iptables -A FORWARD -p all -i br0 -j ACCEPT
sudo ip address add 11.0.0.1/8 dev br0
sudo ip link set br0 up
sudo ip netns add h0
sudo ip link add eth0 netns h0 type veth peer name vethh0
sudo ip link set vethh0 master br0
sudo ip netns exec h0 ip address add 11.0.0.2/8 dev eth0
sudo ip netns exec h0 ip link set dev eth0 up
sudo ip link set dev vethh0 up
sudo ip netns add h1
sudo ip link add eth0 netns h1 type veth peer name vethh1
sudo ip link set vethh1 master br0
sudo ip netns exec h1 ip address add 11.0.0.3/8 dev eth0
sudo ip netns exec h1 ip link set dev eth0 up
sudo ip link set dev vethh1 up
sudo ip netns add h2
sudo ip link add eth0 netns h2 type veth peer name vethh2
sudo ip link set vethh2 master br0
sudo ip netns exec h2 ip address add 11.0.0.4/8 dev eth0
sudo ip netns exec h2 ip link set dev eth0 up
sudo ip link set dev vethh2 up
sudo ip netns add h3
sudo ip link add eth0 netns h3 type veth peer name vethh3
sudo ip link set vethh3 master br0
sudo ip netns exec h3 ip address add 11.0.0.5/8 dev eth0
sudo ip netns exec h3 ip link set dev eth0 up
sudo ip link set dev vethh3 up
sudo ip netns exec h0 ip link add br0 type bridge
sudo ip netns exec h0 ip address add 10.0.0.1/24 dev br0
sudo ip netns exec h0 ip link set br0 up
docker container run --rm --network none --name h0p0 -d -t ubuntu-ping
sudo ln -sf /proc/$(docker inspect -f "{{.State.Pid}}" h0p0)/ns/net /var/run/netns/h0p0
sudo ip link add eth0 netns h0p0 type veth peer name vethh0p0 netns h0
sudo ip netns exec h0 ip link set vethh0p0 master br0
sudo ip netns exec h0p0 ip address add 10.0.0.2/24 dev eth0
sudo ip netns exec h0 ip link set vethh0p0 up
sudo ip netns exec h0p0 ip link set eth0 up
sudo ip netns exec h0p0 ip route add default via 10.0.0.1 dev eth0
docker container run --rm --network none --name h0p1 -d -t ubuntu-ping
sudo ln -sf /proc/$(docker inspect -f "{{.State.Pid}}" h0p1)/ns/net /var/run/netns/h0p1
sudo ip link add eth0 netns h0p1 type veth peer name vethh0p1 netns h0
sudo ip netns exec h0 ip link set vethh0p1 master br0
sudo ip netns exec h0p1 ip address add 10.0.0.3/24 dev eth0
sudo ip netns exec h0 ip link set vethh0p1 up
sudo ip netns exec h0p1 ip link set eth0 up
sudo ip netns exec h0p1 ip route add default via 10.0.0.1 dev eth0
sudo ip netns exec h1 ip link add br0 type bridge
sudo ip netns exec h1 ip address add 10.0.1.1/24 dev br0
sudo ip netns exec h1 ip link set br0 up
docker container run --rm --network none --name h1p0 -d -t ubuntu-ping
sudo ln -sf /proc/$(docker inspect -f "{{.State.Pid}}" h1p0)/ns/net /var/run/netns/h1p0
sudo ip link add eth0 netns h1p0 type veth peer name vethh1p0 netns h1
sudo ip netns exec h1 ip link set vethh1p0 master br0
sudo ip netns exec h1p0 ip address add 10.0.1.2/24 dev eth0
sudo ip netns exec h1 ip link set vethh1p0 up
sudo ip netns exec h1p0 ip link set eth0 up
sudo ip netns exec h1p0 ip route add default via 10.0.1.1 dev eth0
docker container run --rm --network none --name h1p1 -d -t ubuntu-ping
sudo ln -sf /proc/$(docker inspect -f "{{.State.Pid}}" h1p1)/ns/net /var/run/netns/h1p1
sudo ip link add eth0 netns h1p1 type veth peer name vethh1p1 netns h1
sudo ip netns exec h1 ip link set vethh1p1 master br0
sudo ip netns exec h1p1 ip address add 10.0.1.3/24 dev eth0
sudo ip netns exec h1 ip link set vethh1p1 up
sudo ip netns exec h1p1 ip link set eth0 up
sudo ip netns exec h1p1 ip route add default via 10.0.1.1 dev eth0
sudo ip netns exec h2 ip link add br0 type bridge
sudo ip netns exec h2 ip address add 10.0.2.1/24 dev br0
sudo ip netns exec h2 ip link set br0 up
docker container run --rm --network none --name h2p0 -d -t ubuntu-ping
sudo ln -sf /proc/$(docker inspect -f "{{.State.Pid}}" h2p0)/ns/net /var/run/netns/h2p0
sudo ip link add eth0 netns h2p0 type veth peer name vethh2p0 netns h2
sudo ip netns exec h2 ip link set vethh2p0 master br0
sudo ip netns exec h2p0 ip address add 10.0.2.2/24 dev eth0
sudo ip netns exec h2 ip link set vethh2p0 up
sudo ip netns exec h2p0 ip link set eth0 up
sudo ip netns exec h2p0 ip route add default via 10.0.2.1 dev eth0
docker container run --rm --network none --name h2p1 -d -t ubuntu-ping
sudo ln -sf /proc/$(docker inspect -f "{{.State.Pid}}" h2p1)/ns/net /var/run/netns/h2p1
sudo ip link add eth0 netns h2p1 type veth peer name vethh2p1 netns h2
sudo ip netns exec h2 ip link set vethh2p1 master br0
sudo ip netns exec h2p1 ip address add 10.0.2.3/24 dev eth0
sudo ip netns exec h2 ip link set vethh2p1 up
sudo ip netns exec h2p1 ip link set eth0 up
sudo ip netns exec h2p1 ip route add default via 10.0.2.1 dev eth0
sudo ip netns exec h3 ip link add br0 type bridge
sudo ip netns exec h3 ip address add 10.0.3.1/24 dev br0
sudo ip netns exec h3 ip link set br0 up
docker container run --rm --network none --name h3p0 -d -t ubuntu-ping
sudo ln -sf /proc/$(docker inspect -f "{{.State.Pid}}" h3p0)/ns/net /var/run/netns/h3p0
sudo ip link add eth0 netns h3p0 type veth peer name vethh3p0 netns h3
sudo ip netns exec h3 ip link set vethh3p0 master br0
sudo ip netns exec h3p0 ip address add 10.0.3.2/24 dev eth0
sudo ip netns exec h3 ip link set vethh3p0 up
sudo ip netns exec h3p0 ip link set eth0 up
sudo ip netns exec h3p0 ip route add default via 10.0.3.1 dev eth0
docker container run --rm --network none --name h3p1 -d -t ubuntu-ping
sudo ln -sf /proc/$(docker inspect -f "{{.State.Pid}}" h3p1)/ns/net /var/run/netns/h3p1
sudo ip link add eth0 netns h3p1 type veth peer name vethh3p1 netns h3
sudo ip netns exec h3 ip link set vethh3p1 master br0
sudo ip netns exec h3p1 ip address add 10.0.3.3/24 dev eth0
sudo ip netns exec h3 ip link set vethh3p1 up
sudo ip netns exec h3p1 ip link set eth0 up
sudo ip netns exec h3p1 ip route add default via 10.0.3.1 dev eth0
sudo ip netns exec h0 ip route add 10.0.1.0/24 via 11.0.0.3 dev eth0
sudo ip netns exec h1 ip route add 10.0.0.0/24 via 11.0.0.2 dev eth0
sudo ip netns exec h0 ip route add 10.0.2.0/24 via 11.0.0.4 dev eth0
sudo ip netns exec h2 ip route add 10.0.0.0/24 via 11.0.0.2 dev eth0
sudo ip netns exec h0 ip route add 10.0.3.0/24 via 11.0.0.5 dev eth0
sudo ip netns exec h3 ip route add 10.0.0.0/24 via 11.0.0.2 dev eth0
sudo ip netns exec h1 ip route add 10.0.2.0/24 via 11.0.0.4 dev eth0
sudo ip netns exec h2 ip route add 10.0.1.0/24 via 11.0.0.3 dev eth0
sudo ip netns exec h1 ip route add 10.0.3.0/24 via 11.0.0.5 dev eth0
sudo ip netns exec h3 ip route add 10.0.1.0/24 via 11.0.0.3 dev eth0
sudo ip netns exec h2 ip route add 10.0.3.0/24 via 11.0.0.5 dev eth0
sudo ip netns exec h3 ip route add 10.0.2.0/24 via 11.0.0.4 dev eth0
