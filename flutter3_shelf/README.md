# 2025-01-07

在`macOS`中使用`udp`发送数据时, 需要开启 `Network` 才行:

[Runner]->[Signing & Capabilities]->[All]->[App Sandbox]↓

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

# 2025-1-17

在`iOS`中使用`udp`发送数据时, 需要申请 `com.apple.developer.networking.multicast` 权限才行:

https://www.cnblogs.com/chao8888/p/13749383.html

https://developer.apple.com/contact/request/networking-multicast

https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.networking.multicast