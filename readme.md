## Dockerfile 来搭建 kafka

#### 根据 Dockerfile 生成 iamge
语法：`docker build -t imageName:versionNum -f DockerfileName`

###### zookeeper：

```bash
# 创建 zookeeper image
docker build -t elegance/zookeeper:3.4.6 -f zookeeper.Dockerfile
docker images | grep elegance

# 启动 zookeeper
docker run -itd --name zookeeper -h zookeeper -p2181:2181 elegance/zookeeper:3.4.6 bash
# -h: hostName

docker ps
```
###### kafka：

```bash
# 创建 kafka image
docker build -t elegance/kafka-0.9.0.1 -f kafka.0.0.0.1.Dockerfile

# 查看link帮助，下面link zk 的container
docker run --help | grep link 

# 启动 kafka
docker run -itd  --name kafka -h kafka -p9092:9092 --li nk zookeeper elegance/kafka-0.9.0.1 bash
lsof -i:9092 # 查看端口是否被监听
```

###### 测试：

```bash
 # 进入kafka 容器
docker exec -it kafka bash

# 进入目录，可以测试: 创建topic, console-producer, console-consumer
cd /opt/kafka 

# source ~/.bash_profile
# 创建 两个topic
bin/kafka-topics.sh --create --topic test1 --zookeeper zookeeper:2181 --partitions 3 --replication-factor 1
bin/kafka-topics.sh --create --topic test2 --zookeeper zookeeper:2181 --partitions 3 --replication-factor 1

# 查看，列出topic
bin/kafka-topics.sh --describe --topic test1 --zookeeper zookeeper:2181
bin/kafka-topics.sh --describe --topic test2 --zookeeper zookeeper:2181
bin/kafka-topics.sh --list --zookeeper zookeeper:2181

# 新开窗口，启动 console-consumer, 这里使用 zookeeper:2181 ,host 名 zookeeper
bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic test1

# 新开窗口，启动 console-producer
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test1
#控制台输入消息，开始测试

# 测试 kafka-replay-log-producer，用另外一个topic 重复 一个topic的数据
# 关闭上面的 kafka-console 程序
# 订阅 topic2 数据
bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic test2

# 将topic1 的数据在 topic2上重放
bin/kafka-replay-log-producer.sh
bin/kafka-replay-log-producer.sh --broker-list localhost:9092 --zookeeper zookeeper:2181 --inputtopic test1 --outputtopic test2
```

