DEFAULT="$(route | grep '^default' | grep -o '[^ ]*$')"
DEFAULT_IP=$(ip addr show dev "$DEFAULT" | awk '$1 == "inet" { sub("/.*", "", $2); print $2 }')
NAME0="jrs0"

# Crea la imagen
echo -ne "\e[36m## > \e[0mConstruyendo la imagen \e[32mubuntu-ping-python3\e[0m: "
docker build -q -t ubuntu-ping ubuntu-ping >>/dev/null
docker build -q -t ubuntu-ping-python3 .

# Ejecuta dos contenedores
echo -ne "\e[36m## > \e[0mLanzando contenedor \e[32m$NAME0\e[0m: "
docker container run --rm --network none --name $NAME0 -d -t ubuntu-ping-python3

# Obtenemos sus PIDs
PID0="$(docker inspect -f "{{.State.Pid}}" $NAME0)"

# Creamos network namespaces para cada proceso
sudo mkdir -p /var/run/netns
sudo ln -sf /proc/$PID0/ns/net /var/run/netns/$NAME0

# Creamos el bridge
sudo ip link add br0 type bridge

# Enlazamos los namespaces de los contenedores al bridge
sudo ip link add eth0 netns $NAME0 type veth peer name veth$NAME0
sudo ip link set veth$NAME0 master br0

# Asignamos IPs
sudo ip address add 192.168.1.1/30 dev br0
sudo ip netns exec $NAME0 ip address add 192.168.1.2/30 dev eth0

# Levantamos la interfaces
sudo ip link set dev br0 up
sudo ip netns exec $NAME0 ip link set dev eth0 up
sudo ip link set dev veth$NAME0 up

# Permitimos la comunicación por el bridge br0 por el firewall
sudo iptables -A FORWARD -p all -i br0 -j ACCEPT

# Habilitamos la comunicación con el exterior del host
## Dirigimos todo el tráfico IP a través del bridge
sudo ip netns exec $NAME0 ip route add default via 192.168.1.1
## Creamos las reglas del firewall para redirigir el trafico
sudo iptables -A FORWARD -o $DEFAULT -i br0 -j ACCEPT
sudo iptables -A FORWARD -i $DEFAULT -o br0 -j ACCEPT
## Decralamos las reglas de NAT
sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/30 -o $DEFAULT -j MASQUERADE
## Redirigimos el puerto 80 del host al puerto 80 del contenedor
sudo iptables -t nat -A PREROUTING -i $DEFAULT -p tcp --dport 80 -j DNAT --to 192.168.1.2:80
## Permitimos el trafico hacia el contenedor a traves del firewall
sudo iptables -A FORWARD -p tcp -d 192.168.1.2 --dport 80 -j ACCEPT

# Probamos a comunicar con el exterior del host
EXTERNHOST="www.google.com"
echo -e "\e[36m## > \e[0mProbando conexión entre contenedor \e[32m$NAME0\e[0m y \e[32m$EXTERNHOST\e[0m:"
echo -e "\e[36m==================================================\e[0m"
docker exec $NAME0 ping -c 1 $EXTERNHOST
RETVAL=$?
echo -e "\e[36m==================================================\e[0m"
if [ $RETVAL == 0 ]; then
    echo -e "\e[32mConexión realizada con éxito!\e[0m\n"
else
    echo -e "\e[31mConexión fallida.\e[0m\n"
fi

echo -ne "\e[36m## > \e[33mATENCION:\e[0m a continuación debes probar la conexión con el puerto 80 del host ($DEFAULT_IP:80). \e[5;7m(Enter para continuar)\e[0m"
read -p "" yn

# Paramos el contenedor
echo -e "\e[36m## > \e[0mParando el contenedor."
docker kill $(docker container ls -aq) >>/dev/null
sudo unlink /var/run/netns/$NAME0

# Eliminamos la interfaces virtuales
sudo ip link delete br0 type bridge

# Eliminamos las regla del firewall
sudo iptables -D FORWARD -p all -i br0 -j ACCEPT
sudo iptables -D FORWARD -o $DEFAULT -i br0 -j ACCEPT
sudo iptables -D FORWARD -i $DEFAULT -o br0 -j ACCEPT
sudo iptables -t nat -D POSTROUTING -s 192.168.1.2/30 -o $DEFAULT -j MASQUERADE
sudo iptables -t nat -D PREROUTING -i $DEFAULT -p tcp --dport 80 -j DNAT --to 192.168.1.2:80
sudo iptables -D FORWARD -p tcp -d 192.168.1.2 --dport 80 -j ACCEPT
