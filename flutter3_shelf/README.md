# 2025-01-07

在`macOs`使用`udp`发送数据时, 需要开启 `Network` 才行:

[-] Incoming Connections (Server) -允许客户端接收数据

```
<key>com.apple.security.network.server</key>
<true/>
```

[-] Outgoing Connections (Client) -允许客户端发出数据

```
<key>com.apple.security.network.client</key>
<true/>
```
