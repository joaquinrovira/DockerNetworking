# Construcción manual de una red entre contenedores

En este trabajo vamos a manejar los **network namespaces** para establecer un aislamiento apropiado de red. 
Separaremos los contenedores en espacios de nombre de forma que cada contenedor reciba su propia pila de red asilada. 
De esta manera limitaremos la comunicación entre los contenedores que permitamos.

*__Importante__: es necesario tener instalados
[docker](https://docs.docker.com/get-docker/),
[iproute2](https://wiki.linuxfoundation.org/networking/iproute2), 
[iptables](http://www.netfilter.org/projects/iptables/index.html), 
[python3](https://www.python.org/)
.*

``` bash
$ sudo apt install docker-ce docker-ce-cli containerd.io
$ sudo apt install iproute2
$ sudo apt install iptables
$ sudo apt install python3
```

Lanzaremos contendores docker que inicialmente no contarán con red. 
Usaremos la opción ```--network none``` al lanzar contenedores. 
El trabajo está dividido en 4 partes con dificultad incremental. 
Para todas las tareas usaremos una imagen docker llamada ```ubuntu-ping``` que parte de una imagen ```ubuntu``` con el paquete ```iputils-ping``` instalado.

## [Ejercicio 1](1/README.md)
Lanzamiento de contenedores en un mismo host que puedan cominar entre sí mediante protocolos IP.

## [Ejercicio 2](2/README.md)
Lanzamiento de contenedores en un mismo host capaces de comicarse con el host. 
Además, el host también debe poder comunicarse con los contenedores.


## [Ejercicio 3](3/README.md)
Lanzamiento de contenedores capaces de comunicarse con cualquier nodo alcanzable desde el host.
Además, que desde cualquier nodo que pueda alcanzar al host, se pueda establecer algún tipo de comunicación con un contenedor.

## [Ejercicio 4](4/README.md)
Lanzamiento de contenedores desplegados en nodos diferentes que sean capaces de comunicarse entre sí como si estuvieran en la misma LAN.