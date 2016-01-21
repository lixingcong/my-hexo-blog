title: github的ssh-key用法
date: 2016-1-21 21:13:37
tags: github
categories: 读书笔记
---
生成ssh-key可以免密码进入仓库，参考[github官方教程](https://help.github.com/articles/generating-ssh-keys/)

### 确认重名key
一、首先看看有没有之前生成的旧key

	ls -al ~/.ssh
    
若有旧ssh-key，可以选择删除，也可以后来生成时候指定产生新文件名

### 生成key

	# Generate public/private rsa key pair.
	ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
	# passphrase可以不用设置，设置了的话，每次用ssh都要输入

假设生成的自定义ssh-key为私钥 ~/.ssh/id_rsa_github 和 公钥 id_rsa_github.pub。
    
### 本地添加私钥
使得ssh-agent后台运行：

	eval "$(ssh-agent -s)"
    
出现Agent pid XXXX这样的提示之后：

    ssh-add ~/.ssh/id_rsa_github

### 远端添加公钥

打开公钥：【注意是公钥！！】

	cat id_rsa_github.pub
    
将内容拷贝至[https://github.com/settings/ssh](https://github.com/settings/ssh)中，这个key成为完全控制每一个仓库commit权限，要谨慎保存，泄露的话你的github说不定仓库被人清空了。

    
### 联机验证登录

	ssh -T git@github.com
    
添加到本机缓存中，然后github提示You've successfully authenticated。
然后你的deploy key页面的钥匙图标变成绿色，代表可以使用了

### 改用ssh推送

修改你的本地仓库中的config

	vi .git/config
    # 注释掉https
    # url = https://github.com/USERNAME/REPO_NAME.git
    # 更换为ssh,注意有个冒号
    url = git@github.com:USERNAME/REPO_NAME.git
    
++安全提示：++

*强烈建议每一个仓库对应一个key，而不是用一个权限无穷大的key，风险太大。
每个仓库的key可以在下面地址设置：*

	https://github.com/USERNAME/REPO_NAME/settings/keys
    
试一下git push，是不是可以自动推送了。

### 使用Travis CI
可以自动更新博客，这个TC原本的目的不是这样的。
TC原本是代码集成平台，居然用成了博客自动更新机，真是大材小用。

首先关联github账户到travis-IC，然后勾选博客的源代码项目，不是github.io项目。
接下来完成ssh的绑定和.travis.yml修改

在Cloud9上面的虚拟主机操作。因为集成了npm环境。

安装travis：

	gem install travis
    travis login --auto

上传密钥到cloud9，然后放到项目里面，例如我的项目是github.com/aaa/bbb，私钥名称id_rsa_github

	mv id_rsa_github aaa/bbb/
    cd aaa/bbb
    touch .travis.yml
    travis encrypt-file id_rsa_github --add

最后把私钥删除了，留下了这个加密后的私钥。

新建一个ssh配置文件：
	
    vi ssh_config
    # # #
    Host github.com
      User git
      StrictHostKeyChecking no
      IdentityFile ~/.ssh/id_rsa
      IdentitiesOnly yes

编辑：.travis.yml
    
    language: node_js
    node_js:
    - 0.12
    branches:
      only:
      - master
    before_install:
    - openssl aes-256-cbc -K $encrypted_f88d79a9e3f2_key -iv $encrypted_f88d79a9e3f2_iv
      -in id_rsa_github.enc -out ~/.ssh/id_rsa -d
    - chmod 600 ~/.ssh/id_rsa
    - eval $(ssh-agent)
    - ssh-add ~/.ssh/id_rsa
    - cp ssh_config ~/.ssh/config
    - mkdir temp
    - cd temp
    install:
    - npm install -g hexo-cli
    - npm install hexo --save
    - hexo init
    - npm install hexo-generator-index hexo-generator-archive hexo-generator-category hexo-generator-tag hexo-server hexo-deployer-git hexo-renderer-marked@0.2 hexo-renderer-stylus@0.2 hexo-generator-feed@1 hexo-generator-sitemap@1 --save
    before_script:
    - cp -R ../source ./
    - cp -R ../themes ./
    - cp ../_config.yml ./
    - git config --global user.name 'lixingcong'
    - git config --global user.email 'lixingcong@live.com'
    script:
    - hexo clean
    - hexo d -g

实际上，这个文件非常灵活，我是折腾很久才摸索出来的。每个人肯定不一样。我的是以自己的仓库改的，我的仓库地址：[my_hexo_blog](https://github.com/lixingcong/my_hexo_blog)

How to work? 向my_hexo_blog推送的同时，自动更新lixingcong.github.io。

如果遇到问题，可以谷歌关键词“Travis CI Hexo”得到很多结果，可供参考