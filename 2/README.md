## Ejercicio 2

### Lanzamiento de contenedores en un mismo host capaces de comicarse con el host. 

El mecanismo implementado en este ejercicio es el siguiente:
1.  Lanzamos 2 contenedores.
2.  Asignamos su propio network namespace (NS) a cada contenedor.
3.  Creamos un bridge virtual para unificar la comunicación ```host <--> contenedor```.
4. Enlazamos cada proceso con el bridge virtual.
5. Asignamos IPs a las 3 intefaces.
6. Permitimos el paso de paquetes que pasen por el bridge a través del firewall.

Tras esto, probamos el correcto funcionamiento de la conexión. 
En este caso en concreto tendremos dos contenedores el la subred 192.168.1.0/29 de la siguiente manera:

    
    +--------------------------------+  +----------------------------------+
    |                                |  | IP KEYS:                         |
    |                                |  |                                  |
    |   +------+         +------+    |  |   PC subnet      192.168.1.0/29  |
    |   | jrs0 |         | jrs1 |    |  |   + br0   @ host 192.168.1.1     |
    |   +------+         +------+    |  |   + eth0  @ jrs0 192.168.1.2     |
    |   | eth0 |         | eth0 |    |  |   + eth0  @ jrs1 192.168.1.3     |
    |   +--+---+         +--+---+    |  |                                  |
    |      |                |        |  +----------------------------------+
    |   +--+-----+     +----+---+    |
    |   |vethjrs0|     |vethjrs1|    |
    |   +--------+-----+--------+    |
    |   |          br0          |    |
    |   +-----------------------+    |
    |                                |
    |                                |
    +--------------------------------+

##### Generalización

La generalización de este ejecicio es muy sencilla. Primero, deberíamos elegir un subred local con más capacidad de direccionamiento que la 192.168.1.0/29. A partir de ahí, por cada contenedor que queramos conectar, tendremos que enlazar el NS del mismo al bridge.

[Volver](../../..)

[Siguiente ejercicio](../3)