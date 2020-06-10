# CSI scaleflash driver

## Overview
This is a repository for scaleflash CSI Driver.
http://ch.scaleflash.com/

## compatibility
本csi依赖scaleflash存储系统  
os: centos 7.5  
openshift 3.11  

|Branch  | K8s version | openshift | CSI versions | AccessModes     | Status  |
|--------|-------------|-----------|--------------|-----------------|---------|
|v1.0.0  | 1.11 - 1.13 | 3.11      | v1.0 -       | ReadWriteOnce   | release |
|master  | 1.11 - 1.13 | 3.11      | v1.0 -       | ReadWriteOnce   | release |

# kubernetes
### Deploy
#### 部署 csi 插件流程  
1.创建 k8storage namespace  
2.给csi授权  
3.创建nodeplugin  
4.创建controllerplugin  

#### 自动部署脚本
确保当前oc用户有集权管理权限，确定 k8storage namespace 没有使用  
需要自定义安装请修改相应yaml档案，参照shell脚本手动部署  
```
# cd deploy/openshift/
# bash deploy-scaleflash-csi.sh
```

#### 部署成功检查
一个csi-controller-scaleflashplugin-*
每个节点一个csi-node-scaleflashplugin-*
```
[root@node ~]# oc -n k8storage get pod
NAME                                             READY     STATUS    RESTARTS   AGE
csi-controller-scaleflashplugin-f586fb7b-pfg9h   3/3       Running   0          9s
csi-node-scaleflashplugin-c9dcs                  2/2       Running   0          3m
csi-node-scaleflashplugin-prnq5                  2/2       Running   0          3m
csi-node-scaleflashplugin-q982n                  2/2       Running   0          3m
[root@node ~]#
```

### Example



# openshift 3.11
### Deploy
#### 部署scaleflash csi插件流程  
1.创建 k8storage namespace  
2.给csi授权  
3.创建nodeplugin  
4.创建controllerplugin  

#### 自动部署脚本
确保当前oc用户有集权管理权限，确定 k8storage namespace 没有使用  
需要自定义安装请修改相应yaml档案，参照shell脚本手动部署
```
# cd deploy/openshift/
# bash deploy-scaleflash-csi.sh
```

#### 部署成功检查
一个csi-controller-scaleflashplugin-*
每个节点一个csi-node-scaleflashplugin-*
```
[root@node ~]# oc -n k8storage get pod
NAME                                             READY     STATUS    RESTARTS   AGE
csi-controller-scaleflashplugin-f586fb7b-pfg9h   3/3       Running   0          9s
csi-node-scaleflashplugin-c9dcs                  2/2       Running   0          3m
csi-node-scaleflashplugin-prnq5                  2/2       Running   0          3m
csi-node-scaleflashplugin-q982n                  2/2       Running   0          3m
[root@node ~]#
```

### Example
使用参考 examples/ 下的yaml文档，包含两套块存储的pvc  
先部署storageclass 再部署pvc 最后部署应用pod 

参数详细说明 [csi-readme-usage.md](examples/csi-readme-usage.md)  


