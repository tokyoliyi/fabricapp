# Fabric 多机部署步骤

## 前言

本文主要是描述 fabric 的多机部署脚本的使用，同时也会对脚本的一些细节进行解释。

本脚本在 `linux`系统(ubuntu 20.04)进行开发及测试。

本脚本依赖于 docker，需要执行者安装 docker 及 docker-compose，最好安装最新版本。

---

### 脚本构成

部署脚本的地址仓库地址: 

脚本把 fabric 的组件分为如下几部分：

- ca(tls) 组件管理
- peer 组件管理
- orderer 组件管理
- dns 组件（负责多个 host 间的网络通信，可任意定义机构域名）
- explorer 组件，负责可视化网络交易

```shell
.
├── dns
├── explorer
├── orderer
├── peer
├── shared
├── templates
└── tlsca

7 directories, 0 files
```

---

### 脚本文件结构

对于 tlsca/peer/orderer，它们的目录结构是一致的，各自的名字下，包含了一个 `scripts`目录，存放各个 shell/python 脚本。

同时，在脚本执行过程中，还会生成一个与 scripts 目录平级的 `volume`目录，存放必要的与 docker volume 映射的相关文件。

#### volume 目录结构

 在每一个 volume 目录中，包含了 client 及 server 两个目录，server 一般存放的是 ca 的 server 数据，client 存放的是我们需要的各个数据，下面仅对 client 的结构进行说明。

client 下属的结构是 client/orgName，在 orgName 下，包含四个目录及两个 connection 文件。如下所示

```shell
.
├── ca
├── connection.json
├── connection.yaml
├── msp
├── peers
└── users

4 directories, 2 files
```

msp/ 中存放的就是 org 的 msp 结构，这个是需要复制分享给 orderer 节点的，需要复制到 orderere 节点的 orgmsps/orgName/msp  位置。目的是为了创建 channel tx 时使用。

peers 下面存放在的各个 peer 的 ca 资料

users 下面存放的是各个 client/admin 的 ca 资料

ca 下面存放的是 ca 的 admin 的 ca 资料

两个 connection 文件是关于连接此 peer 节点需要的一些配置，application 程序需要使用到这些文件。

---

### 环境变量及脚本配置

为了让脚本更加的通用，使用了部分环境变量来控制脚本的行为。

环境变量包含三个文件

- shared/global.env  - 这是各个组件共享的
- xnode/scripts/local.env  - 这是各个组件自有的本地环境变量，xnode 指的是 tlsca/orderer/peer
- xnode/scripts/user.env - 这是用户自定义的环境变量，如果用户要修改环境变量，一般就是新建一个此名字的文件，然后写入需要修改的内容

整个环境变量的解析过程是按照 global.env -> local.env -> user.env。比如同一个变量 FOO 在三个文件中定义了，那么最终生成的是 user.env 中的值覆盖了前面两个文件的定义。

一般修改的是什么内容？

一般修改修改的是 org 的名字及监听地址等信息。

```shell
# 有一些监听端口的默认值
# 根据名字应该知道其意义
export ORDERER_PORT=7050
export PEER_PORT=7051
export PEER_CHAINCODE_PORT=7052
export PEER_PORT3=7053
export FABRIC_CA_PORT=7054
export ORDERER_ADMIN_PORT=9443

# 这些内容可以在上述的 env 文件中看到
```

---

### 组网步骤

整个组网过程大概为：

1. 规划网络拓扑及域名分配，启动 dns 服务
2. 启动 tls ca，负责整个网络的 tls 通信
3. 启动各个 org 的 ca 及 peer 节点
4. 启动 orderer 的 ca 及 orderer 节点
5. 使用脚本创建 channel
6. 各个 peer 加入 channel
7. 启动 explorer
8. install/commit chaincode 到各个 peer 节点上
9. 验证/做交易，网络部署完成
10. 如果需要创建新的 channel，或者增加/减少 org 到已有 channel 的一些操作。

---

### 路径约定

为了简化文档描述，默认脚本从仓库拉取回来后存放在当前用户的 `HOME`目录中，比如所有的的操作都在 `~/fabricapp`下进行的。

脚本的执行过程中，会从 github 下载 fabric 及其相关的二进制程序包，这些程序包默认存放在 `~/.fabricbin/$VERSION/`下面的。脚本在执行过程中，会在 PATH 中引入这个路径。



下面的文档基本上按照上述的组网过程来描述脚本的使用。

## 使用步骤

### dns 服务启动

dns 服务实际是启动了一个`dnsmasq`来提供 dns 解析服务。

因为我们是多机组网，为了方便各个节点间使用域名形式通信，也为了简化网络规划及域名分配，所以提供了一个 dns 服务，来接管域名与 ip 的映射。

dns 服务的启动步骤是：

1. 根据网络规划，修改 `dnsmasq.conf`配置文件（如果不存在，从 example 复制过去）
2. 修改所有的需要部署的机器的 dns 配置，添加上本 dns 的 ip，作为第一个 dns 解析地址

#### 1. dns 的配置

```shell
├── dnsmasq.conf
├── dnsmasq_example.conf
├── dockers
│   └── dnsmasq.yaml
├── start.sh
└── stop.sh

1 directory, 5 files
```

在 dns 目录下，有如上内容，`dnsmasq_example.conf` 是一个配置例子。

实际使用时，根据网络规划需要，按照例子写入相关配置到 `dnsmasq.conf`文件中，然后执行 `./start.sh`即可启动 dns 服务。

**dnsmasq.conf 文件格式说明**

```shell
server=192.168.2.110
address=/tlsca.fabric.poc/192.168.2.19
address=/.orderer.fabric.poc/192.168.2.20

# 以上面为例子
# 第一个 server=192.168.2.110 指的是本 dns 的上游 dns 服务
# 后面的 address= 后跟的内容，有两种形式
# address=/tlsca.fabric.poc/192.168.2.19 这个是精确，只能解析 tlsca.fabric.poc
# address=/.orderer.fabric.poc/192.168.2.20 这个是通配符(wildcard)形式，比如 p0.orderer.fabric.poc p1.orderer.fabric.poc 都解析到 192.168.2.20 上
```



#### 2. 修改操作系统的 dns 解析地址

dns 一般写在 `/etc/resolve.conf`文件中，但是这个文件中的内容不一定是静态的，它很有可能是从其他文件生成的，仅修改这里，很容易就被覆盖掉了。

（注，不同的 linux 发行版之间，修改的方式不一样，它们之间的行为差异很大，这里不详细描述，具体各个操作系统根据情况修改）



---

### 启动 tls ca

```shell
# 默认情况下
cd tlsca/scripts
./start.sh

# 启动成功后，会把证书复制到 /tmp/tls-ca-cert.pem 处
# 把这个文件分发给所有需要 tls 通信的节点，默认情况下，放在对应的机器的 /tmp/tls-ca-cert.pem 处

# 如果需要定制化，见下面描述
```



**修改域名及其他一些信息**

默认的 top level domain 是 `fabric.test`，可以根据实际修改，使用的变量是 TLD，同时 org name 也可以修改。默认的 tls ca 地址是 tlsca.fabric.test，比如现在想要改成 catls.emali.io.test，那么写入 user.env 中的内容就是

```shell

export TLD=emali.io.test
export ORG_NAME=catls
export CA_CONTAINER_NAME=catls
```

如果需要使用 tls 通信的 peer 及 orderer 节点的地址也不是默认的，那么还需要修改相关的 `REG_ORDERERS` 及 `REG_PEERS`内容。

---

### 启动 peer 节点

在 `peer/scripts`目录下

```shell
# 默认情况下，直接运行 ./start.sh 即可启动
# 这就会启动一个 root ca 及一个 peer 节点，还有对应的 couchdb container
# 如果需要修改 peer 及 org 的名字，新建 user.env 写入对应的变量值即可。
```

**特别注意**

因为脚本是可以重复使用的，所以我们在一台机器上启动了默认的 peer 节点后，在另外一台机器上，那么需要至少修改 org 的名字，否则会出现一模一样的 mspid，网络会组网失败。

修改相关信息，是写入相关数据到 user.env 中，见上面关于环境变量的介绍。

---

### 启动 orderer

在 `orderer/scripts`目录下

```shell
# 默认情况下，直接运行 ./start.sh 即可启动，与启动 peer 类似
# 如果需要修改 orderer 及 org 的名字，新建 user.env 写入对应的变量值即可。
```

---

### 创建 channel

从 fabric 2.3 开始，创建 channel 的步骤进行了简化，但是还是很复杂。在创建 channel 之前，需要做一些准备工作。

- 准备 configtx.yaml 配置，编写相关的 channel 配置
- 准备 configtx.yaml 中指向的各个org 的 global msp 目录文件

#### configtx.yaml 解释

从 fabric 2.3 开始，因为创建 channel 不再需要先创建 system channel 了，所以 configtx.yaml 的结构也发生了一些变化，这些变化主要是不再需要 org 的 consortium 了。

在本脚本中，configtx.yaml 文件的模板是 `orderer/scripts/config/txconfig.yaml`。

在这个文件中，主要关心三部份内容

- Organizations 下属的各个 org 的配置值，在例子中，使用的 MSPDir 的路径是相对路径，以 orgName/msp 为路径，这个路径是因为脚本把所有的 org msp 放在了 `orderer/scripts/orgmsps`目录下，比如 org name 是 bankA，那么就把 bankA 的 msp 放在 `orderere/scripts/orgmsps/bankA/msp`的位置
- 各个 org 及 orderere 的相关的名字、网络地址等值与实际要相符
- Profiles 下属结构，Profiles 下属的第一层 key 即为 `channel profile name`，创建 channel 时，需要使用到这个名字，模板文件中写了三个例子，分别包含了不同的初始化的 org。



#### 创建 channel 步骤

1. 实际使用时，可以直接修改 txconfig.yaml 模板，也可以复制后再修改副本。修改后的文件需要存放到 `orderer/scripts/orgmsps/configtx.yaml`的位置
2. 把要创建的 channel 相关的 org 的 msp 复制到 orderere 节点的 `orderere/scripts/orgmsps/`目录下，以 `orgName/msp`为存放目标，具体的各个 org 的 msp 的位置，见上面的脚本文件目录结构说明。
3. 执行 `./createGenesisChannelBlock.sh`脚本，此脚本有两个参数，第一个参数 configtx.yaml 中定义的 Profiles 里面的名字，第二个参数是要创建的 channel 的名字，比如 `./createGenesisChannelBlock.sh One testonech`
4. 如果配置正确，那么创建成功的 tx 文件就存放在 `orderer/scripts/orgmsps/channelname.tx`处，比如以上面创建的 testonech 为例，那么文件就是 ``orderer/scripts/orgmsps/testonech.tx`
5. 分发这个 tx 文件到需要的各个 org 所属的机器上



---

### 各个 peer 加入 channel

上一步创建的 channel tx 文件复制到各个 peer 所属的机器后。就可以执行下面的步骤。

```shell
# 假设 tx 文件存放在 /tmp/testonech.tx 处
# 当前路径是 ~/fabricapp/peer/scripts
./joinChannel.sh /tmp/testonech.tx

# 上面即可加入网络
# 依次在各个需要的 peer 节点上进行操作即可
```

---

### 启动 explorer

explorer 存放在 `fabricapp/explorer`位置，根据使用时的情况，一般需要修改两个位置

- connection-profile/fabricapp.json 文件，这个文件定义了连接到 peer 所需要的一些名字及地址，以及一个初始化的 channel 名字，需要根据实际情况进行修改
- 程序运行需要在 explorer/crypto 目录结构，这个目录中主要存放了 tls ca 及 admin 的 ca 资料，可以从 `crypto_template`复制过来结构，然后把相关内容填充到对应位置即可

做好上述的配置后，使用 `./start.sh`即可启动，使用 `./stop.sh`即可停止，默认监听在 `0.0.0.0:8080`位置。

---

### install/commit chaincode 到各个 peer 节点

chaincode 的安装步骤主要分为两步

1. 在各个 peer 上 install chaincode
2. 在其中一个 peer 中 commit chaincode



为了说明演示，这里以 org1 及 org2 作为 orgName，channel name 为 two 作为说明

#### public chaincode

首先复制 `fabric-app-starter/chaincode/public`的数据到对应的 peer 节点的对应位置，假设这里存放在 `/tmp/chaincode/public`位置

进入 `peer/scripts/chaincode/public`后，在每一个 peer 先执行 install 相关操作。

```shell
# install.sh 需要五个参数
# 五个参数分别是
# chaincode 的 path
# 要安装的 chaincode 的名字，这里的名字不是指 chaincode 代码的名字，而是我们自己给要安装的 chaincode 取得一个名字，比如 hello
# package version，比如 1.0
# package sequence，初始化安装必须是 1，后续升级安装依次累加
# chaincode 安装的目标 channel 的名字，比如此处例子为 two

./install.sh /tmp/chaincode/public hello 1.0 1 two

# 上面的操作需要在每一个使用到这个 chaincode 的 peer 上安装
```

当 install 成功后，选择其中一个 peer 执行 commit 相关操作

```shell
# 当上一步操作成功，会把输入的参数保存在 last.env 文件中
# 所以执行 commit.sh 时，会从 last.env 中读取相关已经输入的参数值
# 此处  commit.sh 仅添加额外的参数
# 需要的参数是参数的 peer 的地址
# 比如我们有两个 org 的各自一个 peer
# 分别是 peer0.org1.fabric.test:7051 及 peer0.org2.fabric.test:7051
# 那么执行脚本即为
./commit.sh peer0.org1.fabric.test:7051 peer0.org2.fabric.test:7051

# 执行了上面的步骤成功后，chaincode 已经安装成功可以使用了。
```



#### private chaincode

private chaincode 与 public chaincode 的安装步骤一致，只是参数多了两个，分别是 connection file 路径及 signature policy 参数。

复制 `fabric-app-starter/chaincode/private`到 `/tmp/chaincode/priate`位置

```shell
# 因为与 public chaincode 安装一致
# 1. install.sh
# 以 org1 及 org2 为例
# connections.json 文件以 private/example_connections.json 修改复制到 /tmp/chaincode/private/connections.json 文件中
# 那么脚本使用时，需要的 7 个参数为
# chaincode 的 path
# 要安装的 chaincode 的名字，这里的名字不是指 chaincode 代码的名字，而是我们自己给要安装的 chaincode 取得一个名字，比如 hello
# package version，比如 1.0
# package sequence，初始化安装必须是 1，后续升级安装依次累加
# chaincode 安装的目标 channel 的名字，比如此处例子为 two
# endore policy，比如 "OR('org1MSP.member','org2MSP.member')"
# connection file 路径，比如 /tmp/chaincode/private/connections.json
cd peer/scripts/chaincode/private
./install.sh /tmp/chaincode/private privatehello 1.0 1 two "OR('org1MSP.member','org2MSP.member')" /tmp/chaincode/private/connections.json

# 依次在各个 peer 节点上执行此 install 操作
```

当 install 成功后，选择其中一个 peer 执行 commit 相关操作

```shell
# 与 public 的 commit.sh 逻辑一致
# 此处不再赘述
```



---

### 验证/做交易

一个是可以参看日志，在 scripts 下面都有一个 `monitordocker.sh`文件，可以看到相关的日志输出。

---

### 创建一个新的 channel

与直接创建一个 channel 逻辑及步骤一致，在 orderere 节点中，根据相关 profile 创建一个新名字的 channel，然后在相关 peer 节点中操作 join channel 动作即可。

---

### 新添加一个 org 到已有的 channel 中

相关脚本存放在 `peer/scripts/addorg`位置。

整个步骤大概是：

1. 启动新的 org 的 peer，与之前的启动 peer 一致，启动成功后，就有了相关 org 的 msp 及 peer 地址
2. 编写新的 org 的 configtx.yaml 文件，可以根据模板 addorg/nettxconfig.yaml 修改，修改后存放在 addorg/tmp/configtx.yaml 处
3. 把新的 org 的 msp 复制到一个已在相关 channel 中的 peer 节点上，需要注意这里存放的路径需要与上一步的 configtx.yaml 中定义的 MSPDir 中值一致。
4. 执行 addConfig.sh，相关参数见脚本里面的说明
5. 上面生成了变更数据后，需要根据已有的 channel policy 在各个 peer 中进行 sign 操作，所以复制 addorg/signdata 到各个 peer 节点的 addorg/signdata 处
6. 各个 peer 节点执行 sigeUpdate.sh 操作
7. 在其中一个已有 peer 上执行 updateChannel.sh 操作
8. 在新的 peer 节点上，执行 joinChannel.sh 操作，这样，新的 org/peer 加入到已有网络中。





