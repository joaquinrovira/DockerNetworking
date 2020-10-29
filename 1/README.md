## Ejercicio 1

### Lanzamiento de contenedores en un mismo host que puedan cominar entre sí mediante protocolos IP.

El mecanismo implementado en este ejercicio es el siguiente:
1.  Lanzamos 2 contenedores.
2.  Asignamos su propio network namespace (NS) a cada contenedor.
3.  Enlazamos los NS de los contenedores via un enlace ethernet virtual.
3.  Asignamos IPs a las interfaces.

Tras esto, probamos el correcto funcionamiento de la conexión. 
En este caso en concreto tendremos dos contenedores el la subred 192.168.1.0/30 de la siguiente manera:

    PC
    +-----------------------------------------------+ +----------------------------------+
    |                                               | | IP KEYS:                         |
    |                                               | |                                  |
    |    +-NS---------+           +-NS---------+    | |   PC subnet      192.168.1.0/30  |
    |    |            |           |            |    | |   + eth0 @ jrs0  192.168.1.1     |
    |    |            |           |            |    | |   + eth0 @ jrs1  192.168.1.2     |
    |    |    jrs0    |           |    jrs1    |    | |                                  |
    |    |            |           |            |    | +----------------------------------+
    |    |            |           |            |    | 
    |    |            |           |            |    | 
    |    +------------+           +------------+    | 
    |    |    eth0    |           |    eth0    |    | 
    |    +-----+------+           +-----+------+    | 
    |          |                        |           | 
    |          |                        |           | 
    |          +------------------------+           | 
    |                                               | 
    |                                               | 
    +-----------------------------------------------+ 

##### Generalización

La generalización de este set-up implicaría el uso de una interfaz virtual de tipo *bridge* con el fin de reducir el número de conexiones entre hosts de O(n²) a O(n). La ímplementación la veremos en la resolución del siguiente ejercicio.

[Volver](../README.md)

[Siguiente ejercicio](../2/README.md)