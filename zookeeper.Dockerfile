FROM centos:6.6

# 设置 yum 源
RUN mkdir /etc/yum.repos.d/backup &&\
	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ &&\
	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

# 精简的centos, 所以需要额外安装一些软件
RUN yum -y install vim lsof wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel pwgen python-pip nc

# 从官网下载JDK
RUN mkdir /opt/java &&\
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz -P /opt/java

# 解压JDK，设置环境变量
RUN tar zxvf /opt/java/jdk-8u102-linux-x64.tar.gz -C /opt/java &&\
	JAVA_HOME=/opt/java/jdk1.8.0_102 &&\
	sed -i "/^PATH/i export JAVA_HOME=$JAVA_HOME" /root/.bash_profile &&\
	sed -i "s%^PATH.*$%&:$JAVA_HOME/bin%g" /root/.bash_profile &&\
	source /root/.bash_profile

ENV ZOOKEEPER_VERSION "3.4.6"

# 创建zk目录，下载zk到此目录
RUN mkdir /opt/zookeeper &&\
	wget http://mirror.olnevhost.net/pub/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz -P /opt/zookeeper

RUN tar zxvf /opt/zookeeper/zookeeper*.tar.gz -C /opt/zookeeper

# Dockefile 是可以直接调用外面的shell脚本的，以下命令是为了启动zk
# 但是为了方便，不希望有太多文件，只要这个一个文件
# 动态生成启动文件，通过 echo xx >> start.sh 重定向到启动文件中去
RUN echo "source /root/.bash_profile" > /opt/zookeeper/start.sh &&\
	echo "cp /opt/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/conf/zoo_sample.cfg /opt/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/conf/zoo.cfg" >> /opt/zookeeper/start.sh &&\
	echo "[ ! -z $""ZOOKEEPER_PORT"" ] && sed -i 's%.*clientPort=.*$%clientPort='$""ZOOKEEPER_PORT'""%g'  /opt/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/conf/zoo.cfg" >> /opt/zookeeper/start.sh &&\
	echo "[ ! -z $""ZOOKEEPER_ID"" ] && mkdir -p /tmp/zookeeper && echo $""ZOOKEEPER_ID > /tmp/zookeeper/myid" >> /opt/zookeeper/start.sh &&\
	echo "[[ ! -z $""ZOOKEEPER_SERVERS"" ]] && for server in $""ZOOKEEPER_SERVERS""; do echo $""server"" >> /opt/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/conf/zoo.cfg; done" >> /opt/zookeeper/start.sh &&\
	echo "/opt/zookeeper/zookeeper-$"ZOOKEEPER_VERSION"/bin/zkServer.sh start-foreground" >> /opt/zookeeper/start.sh

# 暴露 zk 的 2181端口
EXPOSE 2181    

WORKDIR /opt/zookeeper/zookeeper-${ZOOKEEPER_VERSION}

ENTRYPOINT [ "sh", "/opt/zookeeper/start.sh" ]