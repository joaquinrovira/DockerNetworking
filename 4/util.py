import subprocess
import ipaddress


def host_name(host: int): return f'h{host}'
def host_ip(host: int): return f'11.0.0.{2+host}'
def host_ip_mask(): return '8'
def host_subnet(host: int): return f'10.0.{host}.0'
def host_subnet_mask(): return '24'
def proc_name(host: int, proc: int): return f"{host_name(host)}p{proc}"


def test_cnx(ns_src: str, ip_dest: str):
    print("\033[36m==================================================\033[0m")
    cmd = f"sudo ip netns exec {ns_src} ping -w 3 -c 3 {ip_dest}"
    res = subprocess.run(cmd.split())
    print("\033[36m==================================================\033[0m")
    if res.returncode == 0:
        print(f"\033[32mConexión realizada con éxito!\033[0m\n")
    else:
        print(f"\033[31mConexión fallida.\033[0m\n")


host_net_size = (1 << (32 - int(host_ip_mask()))) - 3


host_subnet_size = (1 << (32 - int(host_subnet_mask()))) - 2
