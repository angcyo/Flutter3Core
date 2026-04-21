# 2023-11-9

## dio

dio 是一个强大的 HTTP 网络请求库，支持全局配置、Restful API、FormData、拦截器、 请求取消、Cookie
管理、文件上传/下载、超时、自定义适配器、转换器等。

https://github.com/cfug/dio
https://github.com/cfug/dio/blob/main/dio/README-ZH.md

- [dio: ^5.3.3](https://pub.dev/packages/dio)
- [json_rpc_2: ^3.0.2](https://pub.dev/packages/json_rpc_2)
- [web_socket_channel: ^2.4.4](https://pub.dev/packages/web_socket_channel)
- [socket_io_client: ^2.0.3+1](https://pub.dev/packages/socket_io_client)

## 核心差异对比表

| **特性**    | **HTTP/1.1**       | **HTTP/2 (2015)**  | **HTTP/3 (2022+)**   |
|-----------|--------------------|--------------------|----------------------|
| **传输层协议** | **TCP**            | **TCP**            | **UDP (基于 QUIC)**    |
| **数据格式**  | 文本 (纯文本)           | **二进制分帧**          | **二进制分帧**            |
| **连接模型**  | 串行/管道化 (持久连接)      | **多路复用** (单一连接)    | **多路复用** (单一连接)      |
| **头部压缩**  | 无 (浪费带宽)           | **HPACK** (静态/动态表) | **QPACK** (适配 UDP)   |
| **握手延迟**  | 高 (TCP + TLS 多次往返) | 较高 (同 1.1)         | **极低 (0-RTT/1-RTT)** |
| **队头阻塞**  | **HTTP 层面阻塞**      | **TCP 层面阻塞**       | **无 (彻底解决)**         |
| **加密**    | 可选 (HTTPS/TLS)     | 事实上的标准 (浏览器要求)     | **内置强制加密 (TLS 1.3)** |

## 请求头处理方式的区别

| 特性        | HTTP/1.1               | HTTP/2 (HPACK)                 | HTTP/3 (QPACK)         |
|-----------|------------------------|--------------------------------|------------------------|
| 格式        | 纯文本，以 \r\n 分隔。         | 二进制格式，分帧传输。                    | 二进制格式，分帧传输。            |
| 压缩算法      | 无压缩。Header 原样发送。       | HPACK 压缩。                      | QPACK 压缩。              |
| 重复 Header | 每次请求都发送完整的 Header。     | 仅发送与上次请求不同的部分。                 | 类似于 H2，但针对 UDP 丢包做了优化。 |
| 伪标头       | 使用 GET / HTTP/1.1 起始行。 | 引入 Pseudo-headers (如 :method)。 | 沿用 HTTP/2 的伪标头机制。      |

Alt-Svc (Alternative Services) 是一种 HTTP 响应首部字段，它允许服务器告知客户端：“虽然你现在通过这个协议/地址访问我，但我其实在另一个地方提供更棒的服务（比如更快的 HTTP/3）。”

https://datatracker.ietf.org/doc/html/rfc7838

- `Alt-Svc: h3=":443"; ma=86400`
- `Alt-Svc: h2=":443"; ma=3600`

