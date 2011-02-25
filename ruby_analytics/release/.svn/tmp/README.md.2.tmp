# 页面访问统计（Ruby版）

## 功能
如同Google Analytics一样，采用客户端的方式，收集用户的网站访问记录。

## 原理
本程序只对Google的ga.js（1.0版本）做了简单的修改，完全是按照其原来的逻辑进行数据的采集。服务器端是通过一个简单的Ruby Rack的程序是实现数据的解析和持久保存。

程序使用的是sqlite3数据库，数据库文件存放在项目的db目录下，每天生成一个文件（格式为：YYYY.mm.dd.sqlite3）。

## 安装以及运行
将本程序按照原有的目录结构拷贝到服务器上的某个路径，假设将本程序安装在`/opt/ruby_analytics`目录下：
进入`/opt/ruby_analytics`，运行一下命令：
    rake bundle:install
该命令将会安装本程序所依赖的其它程序。
**注意**：现在使用的是sqlite3作为数据库，所以运行本命令之前，确保服务器上有sqlite3的头文件和动态库文件。

### 运行方法1：thin
    thin -c /opt/ruby_analytics -e production start
如果还需要其它参数，输入`thin -h`来查看。

### 运行方法2：fastcgi
用fastcgi运行/opt/ruby_analytics/public/dispatch.fcgi脚本。**注意**：需要加上一个变量：`RACK_ENV`，其值为`production`。

## 数据库说明
现在所有的访问数据均存放于一个表中：page_tracks，该表的各个字段说明：
- primary_key :id  主键，标识记录，没太大用处
- Integer :view_code  访问编号，标识unique visit，即是相同的view_code表示同一个人的访问。有效期两年（可设置）
- String :session  会话编号，标识一次会话，会话的过期时间为30分钟（可设置，每次访问更新），或者关闭浏览器后，算是结束一次会话
- String :account  帐号，每个监测都有一个帐号，现在帐号用处不大，使用的是跟我们ga相同的帐号
- String :browser_language  浏览器语言
- String :browser_language_encoding  浏览器的字符编码
- String :referral  页面引用，这是ga所设置的引用，当访问是直接访问时为0；当是站内跳转时为'-'；当是站外跳转时为完整地址
- String :referrer  页面引用，总是完整的页面地址（我添加的）
- String :screen_resolution  用户的屏幕分辨率
- String :screen_color_depth  用户的屏幕色深设置
- String :flash_version  浏览器中falsh插件的版本号
- String :page  访问的页面的路径（不包括域名）
- String :page_title  访问的页面的title
- String :host_name  域名
- String :user_agent  用户浏览器的user agent
- String :campaign_source  广告系列来源
- String :campaign_medium  广告系列媒介
- String :campaign_term  广告系列字词
- String :campaign_content  广告系列内容
- String :campaign_name  广告系列名称
- String :ip 访问者的ip地址
- Boolean :java_enabled  用户的浏览器是否有java插件
- String :viewed_at   这次页面访问的时间
- String :visited_at  这次会话开始的时间
- String :first_visit_time  该用户第一次访问网站的时间
- String :last_visit_time  该用户上一次会话的访问时间

**注意**：
- 广告系列的定义和用途，参考google analytics的相关资料
- 关于时间
  - 记录中的所有时间都是UTC时间，根据需要，可以自己把时间转化成相应时区的时间
  - 时间是js在客户端获取的，好处是，配合使用UTC时间，
    可以清晰的知道用户的访问时间而不受到时区的影响；
    缺点是，时间不受控制，客户端的时间可能不正确
    （不过一般来说，不太会有人故意把自己电脑的时间调乱的）。
  - viewed_at是本次页面访问的时间，是通过服务器端获取的，所以如果当服务器设置有问题或者用户的客户端设置不对，都会导致viewed_at和其他三个时间有所差异
  - 之所以时间都是用字符串的形式保存，是因为数据分析员反应在把数据导入到其他数据库（mysql）时，如果用Datetime类型，导入将很慢

## Copyright
Copyright 和家网 梁智敏 @ 2010
