## Ejercicio 4

### Lanzamiento de contenedores desplegados en nodos diferentes que sean capaces de comunicarse entre sí como si estuvieran en la misma LAN.

Para realizar este ejercicio, como no dispongo de dos hosts, realizaremos una simulacion. La idea es simular el siguiente setup:

    +-----+ +-----+                                                        +-----+ +-----+ 
    | p0  | | p1  |                                                        | p0  | | p1  | 
    +-----+ +-----+                                                        +-----+ +-----+ 
    |veth0| |veth0|                                                        |veth0| |veth0| 
    +--+--+ +--+--+                                                        +--+--+ +--+--+ 
    |       |                                                              |       |  
    +--+--+ +--+--+                                                        +--+--+ +--+--+
    |veth0| |veth1|                                                        |veth0| |veth1|
    +-----+-+-----+---------+                                    +---------+-----+-+-----+ 
    |          br0          |              .-~~~-.               |          br0          | 
    +-----------------------+      .- ~ ~-(       )_ _           +-----------------------+ 
    | Host 0 (h0)           |     /                     ~ -.     | Host 1 (h1)           | 
    +----------------+------+    |        INTERNET          \    +------+----------------+
                    | eth0 +-----\--+                  +---/'---+ eth0 |
                    +------+       ~- . _____________ . -~      +------+

Cada host deberá conocer la IP pública del otro (no puede haber un NAT entre los dos hosts).

El mecanismo implementado en este ejercicio es el siguiente:
1. Creamos el bridge que emula Internet en la conexion entre hosts.
2. Creamos dos hosts virtuales y los conectamos de manera igual al [ejercicio 2](../2).
3. Para cada host:
    1. Lanzamos 2 contenedores.
    2. Los conectamos de manera igual al [ejercicio 2](../2).
    3. Enrutamos los paquetes a las red locales de del otro host via la IP publica del otro host.
    4. Para cada contenedor:
        1. Enrutamos los paquetes a las todas las redes locales via la IP publica del bridge local.

Tras esto, probamos el correcto funcionamiento de la conexión. 
En este caso en concreto tendremos dos contenedores el la subred 10.0.0.0/24 y otros dos contenedores en la subred 10.0.1.0/24.
El bridge pretende emular la interconexión via Internet entre los hosts virtuales:

    PC                                                                                                              
    +-------------------------------------------------------------------------+ +----------------------------------+
    |                                                                         | | IP KEYS:                         |
    |                                                                         | |                                  |
    |                                 +-----+                                 | |   PC subnet       11.0.0.0/8     |
    |   +-----+ +-----+               |     |               +-----+ +-----+   | |   + br0   @ PC    11.0.0.1       |
    |   | p0  | | p1  |               |     |               | p2  | | p3  |   | |   + eth0  @ h0    11.0.0.2       |
    |   +-----+ +-----+               |     |               +-----+ +-----+   | |   + eth0  @ h1    11.0.0.3       |
    |   |veth0| |veth0|               |     |               |veth0| |veth0|   | |                                  |
    |   +--+--+ +--+--+               |     |               +--+--+ +--+--+   | |   h0 subnet       10.0.0.0/24    |
    |      |       |                  |     |                  |       |      | |   + br0   @ h0    10.0.0.1       |
    |   +--+--+ +--+--+               |     |               +--+--+ +--+--+   | |   + veth0 @ p0    10.0.0.2       |
    |   |veth0| |veth1|               |     |               |veth0| |veth1|   | |   + veth0 @ p1    10.0.0.3       |
    |   +-----+-+-----+---------+     |     |     +---------+-----+-+-----+   | |                                  |
    |   |          br0          |     |     |     |          br0          |   | |   h1 subnet       10.0.1.0/24    |
    |   +-----------------------+     |     |     +-----------------------+   | |   + br0   @ h1    10.0.1.1       |
    |   | Host 0 (h0)           |     |     |     | Host 1 (h1)           |   | |   + veth0 @ p2    10.0.1.2       |
    |   +----------------+------+     |     |     +-----------------------+   | |   + veth0 @ p3    10.0.1.3       |
    |                    | eth0 +-----+     +-----+ eth0 |                    | |                                  |
    |                    +------+     | br0 |     +------+                    | +----------------------------------+
    |                                 |     |                                 |
    |                                 |     |                                 |
    |                                 +-----+                                 |
    |                                                                         |
    |                                                                         |
    +-------------------------------------------------------------------------+

#### Generalizacion
Con el fin de proporcionar una generalizacion de este esquema, se proporciona `script.py`, un script de python3 que ejecuta los comandos que ponen en marcha este setup. En función de dos atributos `num_hosts` y `num_procs_per_hosts` que aumentan el número de hosts en la red y el número de contenedores por host. 

Además, genera dos scripts `network_setup.sh` y `network_delete.sh`. El primero, hace el setup de la red por si queremos realizar otras pruebas y el segundo elimina la red generada.

[Volver](../../..)