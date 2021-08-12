# SSH

`ssh -f -N -L 8080:localhost:8080 foo.com`

* `-f` - background
* `-N` - don't execute command on destination
* `-L` - Port forwarding

>      -L [bind_address:]port:host:hostport
>             Specifies that connections to the given TCP port or Unix socket on the local (client) host are to be forwarded to the given host and port, or Unix socket, on the remote side.  This works by allocating a socket to listen to either a TCP port on the local side, optionally bound to the specified bind_address, or to a Unix socket.  Whenever a connection is made to the local port or socket, the connection is forwarded over the secure channel, and a connection is made to either host port hostport, or the Unix socket remote_socket, from the remote machine.
>
>             Port forwardings can also be specified in the configuration file.  Only the superuser can forward privileged ports.  IPv6 addresses can be specified by enclosing the address in square brackets.
>
>             By default, the local port is bound in accordance with the GatewayPorts setting.  However, an explicit bind_address may be used to bind the connection to a specific address.  The bind_address of ``localhost'' indicates that the listening port be bound for local use only, while an empty address or `*' indicates that the port should be available from all interfaces.

* port - The port on the client.
* host - The host on the destination.
* hostport - The port on the destination.

```
// TODO Define host
// TODO Define socket
// TODO Define localhost in context of the command above
```