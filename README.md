# 自签名CA和自签名服务器证书 生成工具

## 1. 生成CA根证书

```bash
./new-root-ca.sh
```

这将生成ca.crt(CA证书)和ca.key(CA私钥)，此操作只需要做一次。

ca.key(CA私钥)及其密码，请妥善保存，不要泄漏。

## 2. 生成服务器证书

```bash
./new-server-cert.sh local.test.org
```

这将生成local.test.org.csr(证书签名申请)和local.test.org.key(私钥)。

```bash
./sign-server-cert.sh local.test.org
```

这将生成local.test.org.crt(证书)。

此处选用域名local.test.org作为例子，这个参数也可以直接是IP，比如192.168.1.10。

另，如果是域名，需要做域名解析(可解析为公网IP，也可以解析为内网IP)或者是修改PC的hosts文件。

## 3. CA根证书和服务器证书的使用

### 3.1 PC

ca.crt(CA证书)发给PC，安装到"受信任的根证书颁发机构"区域。

### 3.2 Nginx SSL

修改nginx.conf，

```
ssl_certificate local.test.org.crt
ssl_certificate_key local.test.org.key
```

重启Nginx。

### 3.3 FreeSWITCH wss

```bash
cat local.test.org.crt local.test.org.key > $FreeSWITCH_ROOT/etc/freeswitch/tls/wss.pem
rm $FreeSWITCH_ROOT/etc/freeswitch/tls/dtls-srtp.pem
```

重启FreeSWITCH。

## 4. 历史记录

以上工具生成的证书和记录，都会存储在ca.db.certs文件夹和ca.db.index、ca.db.index.attr、ca.db.serial文件中。

## 5. 注意事项

请在类Unix环境运行此工具。
