title: nginx反代google
date: 2016-07-31 14:25:13
tags: [html, ubuntu]
categories: 网络
---
一键部署xx之类的脚本使用有风险，试想一下脚本弄出异常的'sudo rm -rf /'就让VPS挂掉，已经有前车之鉴，不敢再偷懒，自己实践下反代过程也不错哦！
<!-- more -->
## nginx

目的是编译带有以下模块的nginx，实现正则表达式匹配谷歌的地址

[ngx\_http\_google\_filter\_module](https://github.com/cuber/ngx_http_google_filter_module)

[ngx\_http\_substitutions\_filter\_module](https://github.com/yaoweibin/ngx_http_substitutions_filter_module)

### 获取module

	mkdir ng cd && cd ng
	git clone https://github.com/cuber/ngx_http_google_filter_module
	git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module
	
安装module依赖

	apt install libpcre3-dev libssl-dev zlib1g-dev libxslt1-dev libgd-dev libgeoip-dev

### 编译nginx

去[nginx download page](http://nginx.org/en/download.html)下载需要的版本，以1.10.1为例

	wget http://nginx.org/download/nginx-1.10.1.tar.gz
	tar xf nginx-1.10.1.tar.gz
	cd nginx-1.10.1
	
configure参数填入，再加上两个Module，生成Makefile

	./configure \
	--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' \
	--with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
	--prefix=/usr/share/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--with-http_ssl_module \
	--with-http_stub_status_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_dav_module \
	--with-http_geoip_module \
	--with-http_gzip_static_module \
	--with-http_image_filter_module \
	--with-http_spdy_module \
	--with-http_sub_module \
	--with-http_xslt_module \
	--add-module=../ngx_http_google_filter_module \
	--add-module=../ngx_http_substitutions_filter_module
	
没有问题就编译安装吧

	make -j2
	make install

看看nginx模块是否正确，方法是看configure末尾是否有ngx\_http\_google\_filter\_module

	nginx -V
	# 若command not found可以创建符号链接
	# ln -s /usr/share/nginx/sbin/nginx /usr/sbin/nginx

然后配置一下网站，看看是否能从外网打开本机网站

	vi /etc/nginx/nginx.conf
	# 修改server_name为自己的域名
	nginx -s reload

## Let's Encrypt证书

### 生成私鈅

挑选一个合适的letsencrypt客户端（网上大约有十多种），我以这个acme-tiny为例

	git clone https://github.com/diafygi/acme-tiny
	cd acme-tiny	

生成自己用于续证书有效期的私钥，用于let's Encrypt识别你的个人身份，需要妥善保管，不能与下面的domain.key混用。

	openssl genrsa 4096 > account.key
	
生成 CSR（Certificate Signing Request，证书签名请求）

1.先生成RSA私钥（实际中可以选用ECC私钥）

	openssl genrsa 4096 > domain.key

2.接下来生成CSR文件

	# 注意：交互式 Common Name 必须输入自己的域名
	openssl req -new -sha256 -key domain.key -out domain.csr

### 签发证书

Let's Encrypt 在你的服务器上生成一个随机验证文件，再通过创建 CSR 时指定的域名访问，如果可以访问则表明你对这个域名有控制权。验证通过才允许下一步签证书。

创建用于存放验证文件的目录，不能用root权限的目录，建议使用nginx的www目录下（貌似权限是www-data？）

	mkdir /var/www/challenges/

往nginx配置一个HTTP服务器，用于验证let's Encrypt域名所有权, 添加前请注释掉之前已经存在的监听80端口的服务器

	vi /etc/nginx/nginx.conf
	# http-server(HTTP)标签内
	server_name MY_DOMAIN.COM;
	
	location ^~ /.well-known/acme-challenge/ {
		alias /var/www/challenges/;
		try_files $uri =404;
	}
	
重载服务

	nginx -s reload
	
这个验证服务以后（比如三个月后）更新证书还要用到，建议一直保留。

有了验证服务器，就可以验证域名并签发证书了。

	cd ~/ng/acme-tiny
	# 注意验证目录是/var/www/challenges，与上面mkdir一致
	python acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir /var/www/challenges/ > ./signed.crt
	
提示*Certificate signed!*就可以生成一个singed.crt网站证书。

接下来还要下载 Let's Encrypt 的中间证书，配置 HTTPS 证书时既不要漏掉中间证书，也不要包含根证书。在 Nginx 配置中，需要把中间证书和网站证书合在一起

	wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem
	cat signed.crt intermediate.pem > chained.pem
	
### 续证书脚本

创建 renew_cert.sh 并通过 chmod a+x renew_cert.sh 赋予执行权限

	#! /bin/bash
	
	export ACME_TINY_DIR=/root/ng/acme-tiny
	
	cd $ACME_TINY_DIR && python acme_tiny.py --account-key account.key --csr domain.csr --acme-dir /var/www/challenges/ > signed.crt || exit
	cd $ACME_TINY_DIR && wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem
	cd $ACME_TINY_DIR && cat signed.crt intermediate.pem > chained.pem
	
	nginx -s reload
	if [ $? = '0' ];then
		echo renew cert ok!
	fi
	
写入crontab，定期执行续证书脚本（比如每个月20号续一次）

## 反代google

	vi /etc/nginx/nginx.conf
	# http标签内加入一个HTTPS服务器
	server {
		server_name MY_DOMAIN.COM;
		listen 443;

		ssl on;
		# specify your cert location
		ssl_certificate /root/ng/acme-tiny/chained.pem;
		ssl_certificate_key /root/ng/acme-tiny/domain.key;

		resolver 8.8.8.8;
		location / {
			google on;
			google_scholar on;
			google_language "en";
		}
		
		# forbid search engine spider
		if ($http_user_agent ~* "qihoobot|Baiduspider|Googlebot|Googlebot-Mobile|Googlebot-Image|Mediapartners-Google|Adsbot-Google|Feedfetcher-Google|Yahoo! Slurp|Yahoo! Slurp China|YoudaoBot|Sosospider|Sogou spider|Sogou web spider|MSNBot|ia_archiver|Tomato Bot"){
			return 403;
		}
	
		# forbid illegal domain request
		if ( $host != "MY_DOMAIN.COM" ) {
			return 403;
		}
	}
	
这样可以实现反代了，重载nginx看看效果

	nginx -s reload

其它设置

设置上游ip，防止谷歌认为你是机器人，要求输入验证码

在vps上面多次使用dig google.com +short获得不同的ip（至少能获取3个吧，多一些比较好），按权重放入upstream标签内

	vi /etc/nginx/nginx.conf
	# http标签内加入upstream上游
	upstream www.google.com{
		server 216.58.217.206:443 weight=34;
		server 172.217.4.142:443 weight=33;
		server 216.58.193.206:443 weight=33;
	}
	
设置同一个ip访问本站频率，防止滥用，具体数值根据服务负荷设置

这里设置某个ip频率每秒10次请求，并发burst最多允许50：效果可以从打开“谷歌图片”搜索一个关键词，看加载图片速度中体会得到。被限制的请求将返回503错误

	# http标签内加入setlimit
	limit_req_zone $binary_remote_addr zone=setfreq:10m rate=10r/s;
	limit_req zone=setfreq burst=50 nodelay;

设置http访问后重定向为baidu.com（纯属恶搞，专门对付那些不开https的人）

	# http-server(HTTP)标签内加入rewrite
	location / {
		# change to your target website
		rewrite ^/(.*)$ http://baidu.com permanent;
	}
	
如果不恶搞，同理可以rewrite为https，达到http跳转https目的

	rewrite ^/(.*)$ https://MY_DOMAIN.COM/$1 permanent;

## 后记

设置到这里就可以使用反代了，建议搭建后域名不要公开使用，亲友几个人使用还是没问题的，人多了你的ip容易被GFW认证，最后只能更换ip

本文来源于项目[ngx\_http\_google\_filter\_module](https://github.com/cuber/ngx_http_google_filter_module)的wiki，还有Let's Encrypt的一篇文章[Let's Encrypt，免费好用的 HTTPS 证书](https://imququ.com/post/letsencrypt-certificate.html)，经过实践记录下来而成。

文中的MY_DOMAIN.COM即你域名，注意替换
