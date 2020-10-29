import subprocess
import ipaddress
import itertools
import sys
import re
from util import *

num_hosts = 3
HOSTS = range(num_hosts)
if num_hosts > host_net_size:
    sys.exit(
        f"Al ser una simulación solo se permiten {host_net_size} hosts virtuales"
    )

num_procs_per_host = 2
PROCS = range(num_procs_per_host)
if num_procs_per_host > host_subnet_size:
    sys.exit(
        f"Al ser una simulación solo se permiten {host_subnet_size} procesos"
    )

f = open('network_setup.sh', 'w')

cmd = 'sudo mkdir -p /var/run/netns'
f.write(cmd + "\n")
subprocess.run(cmd.split())

print("\033[36m## > \033[0mConstruyendo la imagen \033[32mubuntu-ping\033[0m: ", end='')
# Crea la imagen con ping
cmd = 'docker build -q -t ubuntu-ping .'
f.write(cmd + "\n")
s = subprocess.run(cmd.split(), stdout=subprocess.PIPE).stdout.decode('utf-8')
print(s, end='')


# Creamos el bridge que emula Internet para conectar entre los hosts
cmd = 'sudo ip link add br0 type bridge'
f.write(cmd + "\n")
subprocess.run(cmd.split())
# Permitimos la comunicación por el bridge br0 en el firewall
cmd = 'sudo iptables -A FORWARD -p all -i br0 -j ACCEPT'
f.write(cmd + "\n")
subprocess.run(cmd.split())
# Asignamos IP
cmd = f'sudo ip address add {host_ip(-1)}/{host_ip_mask()} dev br0'
f.write(cmd + "\n")
subprocess.run(cmd.split())
# Levantamos la intefaz
cmd = 'sudo ip link set br0 up'
f.write(cmd + "\n")
subprocess.run(cmd.split())


# Conectamos entre hosts virtuales
HOSTS = range(num_hosts)
for h in HOSTS:
    h_name = host_name(h)
    # Creamos el network namespace (NS) para simular al host
    cmd = f'sudo ip netns add {h_name}'
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    # Enlazamos los hosts a "Internet"
    cmd = f'sudo ip link add eth0 netns {h_name} type veth peer name veth{h_name}'
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    cmd = f'sudo ip link set veth{h_name} master br0'
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    # Asginamos IP
    cmd = f'sudo ip netns exec {h_name} ip address add {host_ip(h)}/{host_ip_mask()} dev eth0'
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    # Levantamos las interfaces
    cmd = f'sudo ip netns exec {h_name} ip link set dev eth0 up'
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    cmd = f'sudo ip link set dev veth{h_name} up'
    f.write(cmd + "\n")
    subprocess.run(cmd.split())

h0 = 0
h1 = 1
h_name0 = host_name(h0)
h_name1 = host_name(h1)
h_ip1 = host_ip(h1)
print((f"\033[36m## > \033[0mProbando conexión entre hosts virtuales ") +
      (f"\033[32m{h_name0}\033[0m y \033[32m{h_name1}\033[0m:"))
test_cnx(h_name0, h_ip1)

# Creamos contenedores inter-conectados en cada host
pid = {}
for h in HOSTS:
    pid[h] = {}
    h_name = host_name(h)
    ip_adr = ipaddress.ip_address(host_subnet(h))
    subnet = host_subnet_mask()

    print((f"\033[36m## > \033[0mInicializando host \033[33m{h_name}\033[0m en subred " +
           f"\033[32m{ip_adr}/{subnet}\033[0m."))
    # Creamos el bridge
    cmd = f"sudo ip netns exec {h_name} ip link add br0 type bridge"
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    # Asignamos IP
    cmd = f"sudo ip netns exec {h_name} ip address add {ip_adr + 1}/{subnet} dev br0"
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    # Levantamos la interfaz
    cmd = f"sudo ip netns exec {h_name} ip link set br0 up"
    f.write(cmd + "\n")
    subprocess.run(cmd.split())

    for p in PROCS:
        p_name = proc_name(h, p)
        print((
            f"\033[36m## \033[33m{h_name}\033[36m>" +
            f" \033[0mLanzando contenedor \033[32m{p_name}\033[0m: "), end='', flush=True)
        cmd = f"docker container run --rm --network none --name {p_name} -d -t ubuntu-ping"
        f.write(cmd + "\n")
        subprocess.run(cmd.split())
        cmd = 'docker inspect -f "{{.State.Pid}}" ' + p_name
        s = subprocess.run(cmd.split(), stdout=subprocess.PIPE) \
            .stdout.decode('utf-8')
        pid[h][p] = int(re.search('.*"(.+)".*', s).group(1))
        cmd = f"sudo ln -sf /proc/{pid[h][p]}/ns/net /var/run/netns/{p_name}"
        f.write(
            f'sudo ln -sf /proc/$(docker inspect -f "{{{{.State.Pid}}}}" {p_name})/ns/net /var/run/netns/{p_name}\n'
        )
        subprocess.run(cmd.split())
        cmd = f"sudo ip link add eth0 netns {p_name} type veth peer name veth{p_name} netns {h_name}"
        f.write(cmd + "\n")
        subprocess.run(cmd.split())
        cmd = f"sudo ip netns exec {h_name} ip link set veth{p_name} master br0"
        f.write(cmd + "\n")
        subprocess.run(cmd.split())
        cmd = f"sudo ip netns exec {p_name} ip address add {ip_adr + 2 + p}/{subnet} dev eth0"
        f.write(cmd + "\n")
        subprocess.run(cmd.split())
        cmd = f"sudo ip netns exec {h_name} ip link set veth{p_name} up"
        f.write(cmd + "\n")
        subprocess.run(cmd.split())
        cmd = f"sudo ip netns exec {p_name} ip link set eth0 up"
        f.write(cmd + "\n")
        subprocess.run(cmd.split())
        cmd = f"sudo ip netns exec {p_name} ip route add default via {ip_adr + 1} dev eth0"
        f.write(cmd + "\n")
        subprocess.run(cmd.split())

    print("")


h = 0
p0 = 0
p1 = 1
p_name0 = proc_name(h, p0)
p_name1 = proc_name(h, p1)
p_ip1 = ipaddress.ip_address(host_subnet(h)) + 2 + p1
print((f"\033[36m## > \033[0mProbando conexión entre procesos de un mismo host ") +
      (f"\033[32m{p_name0}\033[0m y \033[32m{p_name1}\033[0m:"))
test_cnx(p_name0, p_ip1)

# Conectamos los conetenedores para comunicacion entre hosts
for hi, hj in itertools.combinations(HOSTS, r=2):
    h_name_i = host_name(hi)
    net_ip_adr_i = host_ip(hi)
    ip_adr_i = ipaddress.ip_address(host_subnet(hi))
    h_name_j = host_name(hj)
    net_ip_adr_j = host_ip(hj)
    ip_adr_j = ipaddress.ip_address(host_subnet(hj))
    cmd = f"sudo ip netns exec {h_name_i} ip route add {ip_adr_j}/{host_subnet_mask()} via {net_ip_adr_j} dev eth0"
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    cmd = f"sudo ip netns exec {h_name_j} ip route add {ip_adr_i}/{host_subnet_mask()} via {net_ip_adr_i} dev eth0"
    f.write(cmd + "\n")
    subprocess.run(cmd.split())


h0 = 0
h1 = HOSTS[-1]
p0 = 0
p1 = PROCS[-1]
p_name0 = proc_name(h0, p0)
p_name1 = proc_name(h1, p1)
p_ip1 = ipaddress.ip_address(host_subnet(h1)) + 2 + p
print((f"\033[36m## > \033[0mProbando conexión entre procesos en hosts diferentes ") +
      (f"\033[32m{p_name0}\033[0m y \033[32m{p_name1}\033[0m:"))
test_cnx(p_name0, p_ip1)


f.close()
f = open('network_delete.sh', 'w')

# Borramos la red virtual
print("\033[36m## > \033[0mEliminando intefaces virtuales.")
cmd = "sudo ip link delete br0 type bridge"
f.write(cmd + "\n")
subprocess.run(cmd.split())
cmd = "sudo iptables -D FORWARD -p all -i br0 -j ACCEPT"
f.write(cmd + "\n")
subprocess.run(cmd.split())

# Desenlazamos NS
for h in HOSTS:
    h_name = host_name(h)
    cmd = f"sudo ip netns delete {h_name}"
    f.write(cmd + "\n")
    subprocess.run(cmd.split())
    for p in PROCS:
        cmd = f"sudo ip netns delete {proc_name(h,p)}"
        f.write(cmd + "\n")
        subprocess.run(cmd.split())

# Paramos contenedores
print("\033[36m## > \033[0mParando los contenedores.")
cmd = "docker container ls -aq"
pids = subprocess.run(cmd.split(), stdout=subprocess.PIPE) \
    .stdout.decode('utf-8').splitlines()
cmd = f"docker stop {' '.join(pids)}"
f.write("docker stop $(docker container ls -aq) >>/dev/null" + "\n")
subprocess.run(cmd.split(), stdout=subprocess.DEVNULL)

f.close()
