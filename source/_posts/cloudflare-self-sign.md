title: Cloudflare自签名SSL证书
date: 2016-12-20 09:50:14
tags: [html, nginx, 转载]
categories: 网络
---
将自签名的openssl证书与cloudflare配合使用，达到CDN效果。
<!-- more -->
let's encrypt的证书每三个月都要续签，即便可以用脚本实现，但是我这个懒人还是想一劳永逸：签证一次以后也不需要再签名，而且证书“不会过期”，那是坠吼的！

## 前戏

确保cloudflare中的DNS记录为DNS only（仅解析DNS），先不急着上CDN。待调试成功再开启HTTP Proxy CDN。

## 自签名

自签名需要生成两个密钥，一个用于自造CA，另一个用作泛域名。

切换当前目录

	cd /tmp/test-cert

### 自造CA证书

创建一个私钥用于CA，这里使用ECC证书（如果使用RSA证书，可以使用genrsa参数）

	openssl ecparam -genkey -name prime256v1 -out ca.key
	
生成CA根证书，参数days后面的7305是指证书的有效期，这里设置成了20年，也就是CA是20年有效。执行后随意填信息，但是Common Name必须填上自己的域名，比如example.com

	openssl req -new -x509 -days 7305 -key ca.key -out ca.crt

ca.crt就是自造的根域名CA证书。

### 泛域名证书

创建一个私钥用于泛域名

	openssl ecparam -genkey -name prime256v1 -out domain.key
	
生成签名请求：遇到Common Name必须填上自己的泛域名（带星号），比如*.example.com

	openssl req -new -sha256 -key domain.key -out domain.csr
	
domain.csr就是自造的域名CSR，用于下文的签证书。
	
### CA自签证

找到openssl.cnf文件，拷贝一份，我的是ubuntu，不同系统也许位置不一样。但是内容是一致的。

	cp /etc/ssl/openssl.cnf ./openssl.cnf
	
打开这个openssl.cnf，发现有如下两行，指定了新生成的证书目录，根据实际情况修改dir的值。这个dir目录下存放的应该是签证的中间文件，一般没什么用途。签完证书可以忽略掉这个目录。

	dir  = ./demoCA   # TSA root directory
	dir  = ./demoCA   # Where everything is kept
	
由于我没有改dir的值，那么就在当前目录下建立一个demoCA文件夹。

	mkdir demoCA
	
修改各种默认参数，用于openssl自签名，我直接抄来的：

	mkdir demoCA/newcerts
	touch demoCA/index.txt
	echo "01" > demoCA/serial
	
开始签名，使用指定的openssl.cnf文件，签名有效期20年。。。

	openssl ca -policy policy_anything \
	  -days 7305 -cert ca.crt -keyfile ca.key \
	  -in domain.csr -out signed.crt \
	  -config ./openssl.cnf

将根证书和泛域名证书合成一个full-chain证书

	cat signed.crt ca.crt > fullchain.pem
	
在下一步部署nginx，我们只需要以下两个文件
- domain.key
- fullchain.pem

自造CA可以选择留存下来，下次可以再签新证书。再签的时候需要重新删除并做一个demoCA目录。否则提示*TXT_DB error number 2*

## 部署

### nginx

在监听80端口的server标签中，强制http跳转到https。

	location / {
		rewrite ^(.*)$  https://$host$1 permanent;
	}

在监听443端口server标签中修改

	listen 443 ssl;
	ssl_certificate /tmp/test-cert/fullchain.pem
	ssl_certificate_key /tmp/test-cert/domain.key
	
测试配置是否正确(test)，正确就reload

	nginx -t && nginx -s reload

打开网站看看效果，肯定提示证书不被信任（自签证书），跟12306网站一样。忽略这个警告，进入网站，确认无误就可以开启cloudflare的CDN了。

### cloudflare

大致就是如下步骤
- 在cloudflare中的DNS选项卡，右侧的Status选择"HTTP proxy,CDN"。
- 注意cloudflare在切换HTTP CDN模式和DNS Only模式有一定的延时，可能是DNS缓存。有时候修改记录后一分钟后就生效了，有时候却等几个小时才生效。耐心等候。
- 在cloudflare中的crypto选项卡，SSL模式选择Full。

## 其它

### 清除HPKP

之前有证书，且部署了HPKP，使用自签证书后，chrome提示如下错误

	NET::ERR_SSL_PINNED_KEY_NOT_IN_CERT_CHAIN
	
由于我的网站使用了pinned SHA256，在浏览器中清除以前的HPKP记录即可

	# 打开并删除自己网站记录
	chrome://net-internals/#hsts
	
可以使用ca.crt重新生成pinned key，放入到nginx配置中

	openssl x509 -in ca.crt -noout -pubkey | openssl asn1parse -noout -inform pem -out ca.pubkey
	HPKP_SHA256=`openssl dgst -sha256 -binary ca.pubkey | openssl enc -base64`
	echo $HPKP_SHA256
	
当然，若要使用cloudflare，必须或cloudflare中间证书的SHA256值，而不是自签CA的。

我的方法是打开这个[SSLlabs网站](https://www.ssllabs.com)，填入自己域名，点测试，查看中间证书的SHA256值，然后手动加入到nginx里面的。

![](/images/cloudflare_self_sign/ssllabs.png)

从上图可以看出，加入到nginx的代码如下

	add_header Public-Key-Pins 'pin-sha256="x9SZw6TwIqfmvrLZ/kz1o0Ossjmn728BnBKpUFqGNVM="; max-age=2592000;';

## 原文链接

[自签名ssl证书+cloudflare](https://www.eaimty.com/2016/10/encrypt-site-with-customs-and-cloudflare-ssl.html)