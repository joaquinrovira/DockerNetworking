## Ejercicio 3

### Lanzamiento de contenedores capaces de comunicarse con cualquier nodo alcanzable desde el host.

El mecanismo implementado en este ejercicio es el siguiente:
1.  Lanzamos 1 contenedor.
2.  Asignamos su propio network namespace (NS) a cada contenedor.
3.  Creamos un bridge virtual para unificar la comunicación ```host <--> contenedor```.
4. Enlazamos el proceso con el bridge virtual.
5. Asignamos IPs a las 2 intefaces.
6. Permitimos el paso de paquetes que pasen por el bridge a través del firewall.
7. Indicamos en el firewall que queremos hacer NATing con los paquetes que procedan del bridge y se dirigan hacia internet via la interfaz por defecto del host.
8. Redirigimos el trafico por defecto de los contenedores a a traves del host.
9. Por último, redirigimos el trafico del puerto 80 del host hacia el puerto 80 de contenedor. Donde habrá un sencillo servidor http escuchando.

Tras esto, probamos el correcto funcionamiento de la conexión. 
En este caso en concreto tendremos dos contenedores el la subred 192.168.1.0/30 de la siguiente manera:

    
    +-------------------------------+  +----------------------------------+
    |                               |  | IP KEYS:                         |
    |                               |  |                                  |
    |                               |  |                                  |
    |   +------+                    |  |   PC subnet      192.168.1.0/30  |
    |   | jrs0 |                    |  |   + br0   @ host 192.168.1.1     |
    |   +------+                    |  |   + eth0  @ jrs0 192.168.1.2     |
    |   | eth0 |                    |  |                                  |
    |   +--+---+                    |  +----------------------------------+
    |      |                        |
    |   +--+-----+                  |
    |   |vethjrs0|                  |
    |   +--------+--------------+   |    ***
    |   |          br0          |   |     I 
    |   +-----------------------+   |     N 
    |   | Host                  |   |     T 
    |   +-------------+---------+   |     E 
    |                 | DEFAULT +------>  R 
    |                 +---------+   |     N 
    |                               |     E 
    |                               |     T 
    |                               |    ***
    +-------------------------------+


##### Generalización

De la misma manera que en el ejercicio anterior. Primero, deberíamos elegir un subred local con más capacidad de direccionamiento que la 192.168.1.0/30. A partir de ahí, por cada contenedor que queramos conectar, tendremos que enlazar el NS del mismo al bridge. Además redirigir el tráfico por defecto a través del bridge.

[Volver](../../..)

[Siguiente ejercicio](../4)