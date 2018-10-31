# SSH Tunnel

This [sshtunnel](https://hub.docker.com/r/binlab/sshtunnel) provides a simple way to create an `SSH` tunnel to a
remote machine or infrastructure to securely connect without a
possibility to expose your host in world. Or if you need to access to
remote database from a local IP `127.0.0.1` or local network

## Usage

### Private key 

The container assumes your private key doesn't have a password and is
mounted under `/sshtunnel_rsa` with `644` permissions.

example for a Docker:

    -v $(pwd)/remote_server.pem:/sshtunnel_rsa:ro

### Configuration

All configuration is set as additional parameters for Docker container, for example:

    -R *:2222:127.0.0.1:22 user@public.server.com

# Usage cases

One of the cases when you have a remote machine behind a `NAT` without
white IP and any acesses to `Firewall/NAT/Router` and you wish to
connect to remote machine from a world via `SSH`.

For this scenario, we a use `-R` option of `SSH` as said in an official
documentation:

```
-R [bind_address:]port:host:hostport
-R [bind_address:]port:local_socket
-R remote_socket:host:hostport
-R remote_socket:local_socket
-R [bind_address:]port
Specifies that connections to the given TCP port or Unix socket on the
remote (server) host are to be forwarded to the local side.
This works by allocating a socket to listen to either a TCP port or to a
Unix socket on the remote side. Whenever a connection is made to this
port or Unix socket, the connection is forwarded over the secure channel,
and a connection is made from the local machine to either an explicit
destination specified by host port hostport, or local_socket, or, if no
explicit destination was specified, ssh will act as a SOCKS 4/5 proxy and
forward connections to the destinations requested by the remote SOCKS
client.
Port forwardings can also be specified in the configuration file.
Privileged ports can be forwarded only when logging in as root on the
remote machine. IPv6 addresses can be specified by enclosing the address
in square brackets.
By default, TCP listening sockets on the server will be bound to the
loopback interface only. This may be overridden by specifying a
bind_address. An empty bind_address, or the address ‘*’, indicates that
the remote socket should listen on all interfaces. Specifying a remote
bind_address will only succeed if the server's GatewayPorts option is
enabled (see sshd_config(5)).
If the port argument is ‘0’, the listen port will be dynamically
allocated on the server and reported to the client at run time. When
used together with -O forward the allocated port will be printed to the
standard output.
```

## 1. Connect to Remote Machine via `SSH` behind a `NAT`

Schematic of this case figure below:

    --------------------------------------------------------------------
                                                                        
                   |             |                                      
    +-----------+  |             |  +----------+                        
    |  REMOTE   |  |             |  |  PUBLIC  | *:22    Public Server   
    |  MACHINE  | ====== SSH =====> |  SERVER  | *:2222  Remote Machine 
    +-----------+  |             |  +----------+                        
                   |             |                                      
                  NAT         FIREWALL (SSH: 22 Open)                   
                                                                        
    --------------------------------------------------------------------

Config string of implementation:

    -R *:2222:127.0.0.1:22

Docker example:

```
$ docker run --rm \
    --name sshtunnel \
    --network host \
    -v $(pwd)/public_server.pem:/sshtunnel_rsa:ro \
    binlab/sshtunnel \
    '-R *:2222:127.0.0.1:22' \
    'user@public.server.com'
```

Docker-compose example:

```
  sshtunnel:
    image: binlab/sshtunnel
    container_name: sshtunnel
    restart: always
    command: |
      -R *:2222:127.0.0.1:22
      user@public.server.com
    volumes:
      - ./public_server.pem:/sshtunnel_rsa:ro
    network_mode: host
```

## 2. Connect to Nginx in Docker on Remote Machine behind a `NAT`

Schematic of this case figure below:

    --------------------------------------------------------------------
    Nginx in Docker                                                     
    +------------+  |             |                                     
    | +--------+ |  |             |  +----------+                       
    | | DOCKER | |  |             |  |  PUBLIC  | *:22  Local SSH       
    | +--------+ | ====== SSH =====> |  SERVER  | *:80  Remote Nginx    
    |   REMOTE   |  |             |  |  GATEWAY |                       
    |   MACHINE  |  |             |  +----------+                       
    +------------+  |             |                                     
                   NAT         FIREWALL (SSH: 22 Open)                  
    --------------------------------------------------------------------


Config string of implementation:

    -R *:80:nginx_container:80

Docker example:

```
$ docker run --rm \
    --name sshtunnel \
    --hostname sshtunnel \
    --link nginx-public \
    -v $(pwd)/public_server.pem:/sshtunnel_rsa:ro \
    binlab/sshtunnel \
    '-R *:80:nginx-public:80' \
    'user@public.server.com'
```

Docker-compose example:

```
  sshtunnel:
    image: binlab/sshtunnel
    container_name: sshtunnel
    hostname: sshtunnel
    restart: always
    command: |
      -R *:80:nginx-public:80
      user@public.server.com
    volumes:
      - ./public_server.pem:/sshtunnel_rsa:ro
    depends_on:
      - nginx-public
```








