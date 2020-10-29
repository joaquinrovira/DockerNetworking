NAME0="jrs0"
NAME1="jrs1"
IPH="192.168.1.1"
IP0="192.168.1.2"
IP1="192.168.1.3"

# Crea la imagen con ping
echo -ne "\e[36m## > \e[0mConstruyendo la imagen \e[32mubuntu-ping\e[0m: "
docker build -q -t ubuntu-ping .

# Ejecuta dos contenedores
echo -ne "\e[36m## > \e[0mLanzando contenedor \e[32m$NAME0\e[0m: "
docker container run --rm --network none --name $NAME0 -d -t ubuntu-ping
echo -ne "\e[36m## > \e[0mLanzando contenedor \e[32m$NAME1\e[0m: "
docker container run --rm --network none --name $NAME1 -d -t ubuntu-ping

# Obtenemos sus PIDs
PID0="$(docker inspect -f "{{.State.Pid}}" $NAME0)"
PID1="$(docker inspect -f "{{.State.Pid}}" $NAME1)"

# Creamos network namespaces para cada proceso
sudo mkdir -p /var/run/netns
sudo ln -sf /proc/$PID0/ns/net /var/run/netns/$NAME0
sudo ln -sf /proc/$PID1/ns/net /var/run/netns/$NAME1

# Creamos el bridge
sudo ip link add br0 type bridge

# Enlazamos los namespaces de los contenedores al bridge
sudo ip link add eth0 netns $NAME0 type veth peer name veth$NAME0
sudo ip link add eth0 netns $NAME1 type veth peer name veth$NAME1
sudo ip link set veth$NAME0 master br0
sudo ip link set veth$NAME1 master br0

# Asignamos IPs
sudo ip address add $IPH/29 dev br0
sudo ip netns exec $NAME0 ip address add $IP0/29 dev eth0
sudo ip netns exec $NAME1 ip address add $IP1/29 dev eth0

# Levantamos la interfaces
sudo ip link set dev br0 up
sudo ip netns exec $NAME0 ip link set dev eth0 up
sudo ip link set dev veth$NAME0 up
sudo ip netns exec $NAME1 ip link set dev eth0 up
sudo ip link set dev veth$NAME1 up

# La comunicación está bloqueada por el firwall (iptables)
# Permitimos la comunicación por el bridge br0 por el firewall
sudo iptables -A FORWARD -p all -i br0 -j ACCEPT

# Probamos a comunicar entre contenedores
echo -e "\e[36m## > \e[0mProbando conexión entre contenedor \e[32m$NAME0\e[0m y contenedor \e[32m$NAME1\e[0m:"
echo -e "\e[36m==================================================\e[0m"
echo -ne "\e[32m[FROM $IP0]\e[0m "
docker exec $NAME0 ping -c 1 $IP1
RETVAL=$?
echo -e "\e[36m==================================================\e[0m"
if [ $RETVAL -eq 0 ]; then
    echo -e "\e[32mConexión realizada con éxito!\e[0m\n"
else
    echo -e "\e[31mConexión fallida.\e[0m\n"
fi

echo -e "\e[36m## > \e[0mProbando conexión entre contenedor \e[32m$NAME0\e[0m y \e[32mHOST\e[0m:"
echo -e "\e[36m==================================================\e[0m"
echo -ne "\e[32m[FROM $IP0]\e[0m "
docker exec $NAME0 ping -c 1 $IPH
RETVAL=$?
echo -e "\e[36m==================================================\e[0m"
if [ $RETVAL -eq 0 ]; then
    echo -e "\e[32mConexión realizada con éxito!\e[0m\n"
else
    echo -e "\e[31mConexión fallida.\e[0m\n"
fi

echo -e "\e[36m## > \e[0mProbando conexión entre contenedor \e[32m$NAME1\e[0m y \e[32mHOST\e[0m:"
echo -e "\e[36m==================================================\e[0m"
echo -ne "\e[32m[FROM $IP1]\e[0m "
docker exec $NAME1 ping -c 1 $IPH
RETVAL=$?
echo -e "\e[36m==================================================\e[0m"
if [ $RETVAL -eq 0 ]; then
    echo -e "\e[32mConexión realizada con éxito!\e[0m\n"
else
    echo -e "\e[31mConexión fallida.\e[0m\n"
fi

# Paramos los contenedores
echo -e "\e[36m## > \e[0mParando los contenedores."
docker stop $(docker container ls -aq) >>/dev/null
sudo unlink /var/run/netns/$NAME0
sudo unlink /var/run/netns/$NAME1

# Eliminamos la interfaces virtuales
sudo ip link delete br0 type bridge

# Eliminamos las regla del firewall
sudo iptables -D FORWARD -p all -i br0 -j ACCEPT
