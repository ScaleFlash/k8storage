# USAGE

# 0. Description
1个storageclas对应一个pvc对应一个pod  
如果有三个pod需要挂载3个pvc那么需要建立3个对应的storageclas  

# 1. create storageclass
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: sf-csi-sc-demo-lun1
provisioner: csi-scaleflash
parameters:
    zkServerList: "192.168.68.84:2181,192.168.68.85:2181,192.168.68.86:2181"
    storID: "stor_001"
    clstID: "k8storage"
    lunName: "demo-lun1"
    fsType: "xfs"
    lunPass: ""
    lunReadQos: "0"
    lunWriteQos: "0"
    capacity: "100"
    snapCount: "0"
    encryptData: "0"
reclaimPolicy: Delete
volumeBindingMode: Immediate

参数说明
name: sf-csi-sc-demo-lun1
    StorageClass name

zkServerList: "192.168.68.84:2181,192.168.68.85:2181,192.168.68.86:2181"
    zookeeper 集群服务器列表, 格式为 ip:port,ip:port

storID: "stor_001"
    集群上的存储系统名称

clstID: "k8storage"
    客户端控制名字

lunName: "demo-lun1"
    lun 的设备名称 (/dev/demo-lun1)

fsType: "xfs"
    mount 格式 ext3/ext4/xfs

lunPass: ""
    带有密码的lun设备,节点加载磁盘需要提供本密码,首次使用提供

lunReadQos: "0"
lunWriteQos: "0"
    IOPS 每秒io个数 ， lun 设备目前只支持针对 IOPS 的 QoS 控制.

capacity: "100"
    lun 设备大小，单位(GB)

snapCount: "0"
    做多支持快照个数,首次使用提供

encryptData: "0"
    落盘数据加密 为0表示不加密，非0表示加密,首次使用提供

```
# 2. create pvc
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sf-csi-pvc-demo-lun1             # pvc name
spec:
  accessModes:
  - ReadWriteOnce                        # accessModes ReadWriteOnce
  resources:
    requests:
      storage: 100Gi                     # size
  storageClassName: sf-csi-sc-demo-lun1  # StorageClass name
```

# 3. Application mount
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: sf-csi-pod-demo-lun1
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sf-csi-pod-demo-lun1
  template: 
    metadata:
      labels:
        app: sf-csi-pod-demo-lun1
    spec:
      serviceAccount: csi-service-account
      containers:
      - name: centos-sf-csi-pod-demo-lun1
        image: centos:7.6.1810
        imagePullPolicy: IfNotPresent
        command: [ "sleep", "99999" ]
        volumeMounts:
        - name: k8storage
          mountPath: "/data"
      volumes:
      - name: k8storage
        persistentVolumeClaim:
          claimName: sf-csi-pvc-demo-lun1
```

# EXAMPLES

## kubernetes 环境
```


```


## openshift-3.11 环境
```
执行案例检查状态

[root@node84 ~]# oc apply -f demo-lun1-sc-pvc-app.yaml
storageclass.storage.k8s.io/sf-csi-sc-demo-lun1 created
persistentvolumeclaim/sf-csi-pvc-demo-lun1 created
statefulset.apps/sf-csi-pod-demo-lun1 created
[root@node84 ~]#
[root@node84 ~]# oc get storageclass
NAME                  PROVISIONER      AGE
sf-csi-sc-demo-lun1   csi-scaleflash   1h
[root@node84 ~]# 
[root@node84 ~]# oc get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                          STORAGECLASS          REASON    AGE
pvc-6a658182-7d41-11ea-bd22-000c29a12090   100Gi      RWO            Delete           Bound     default/sf-csi-pvc-demo-lun1   sf-csi-sc-demo-lun1             1h
[root@node84 ~]# 
[root@node84 ~]# oc get pvc
NAME                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
sf-csi-pvc-demo-lun1   Bound     pvc-6a658182-7d41-11ea-bd22-000c29a12090   100Gi      RWO            sf-csi-sc-demo-lun1   1h
[root@node84 ~]#
[root@node84 ~]# oc get pod | grep sf-csi-pod-demo-lun1
sf-csi-pod-demo-lun1-0                            1/1       Running   0          1h
[root@node84 ~]#
[root@node84 ~]# oc rsh sf-csi-pod-demo-lun1-0 
sh-4.2$ df -hT | grep data
/dev/demo-lun1          xfs      100G   33M  100G   1% /data
sh-4.2$ touch /data/test 
sh-4.2$ echo "ttttt" > /data/test 
sh-4.2$ cat /data/test 
ttttt
sh-4.2$ exit
exit
[root@node84 ~]#

```

## 扩容

思路：  
1 获取当前前 storageclass pvc app-pod 的yaml档案   
2 删除 storageclass pvc app-pod  
3 修改 storageclass 和 pvc 中容量参数  
4 重新部署 storageclass pvc app-pod  

注意： 
  只能扩容  

```
# 生成测试文件
dd if=/dev/urandom of=/data/file1 bs=1M count=1024 oflag=direct,nonblock status=progress
dd if=/dev/urandom of=/data/file2 bs=1M count=1024 oflag=direct,nonblock status=progress
dd if=/dev/urandom of=/data/file3 bs=1M count=1024 oflag=direct,nonblock status=progress


[root@node84 ~]# oc get pvc
NAME                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
sf-csi-pvc-demo-lun1   Bound     pvc-6a658182-7d41-11ea-bd22-000c29a12090   100Gi      RWO            sf-csi-sc-demo-lun1   1h
[root@node84 ~]# 
[root@node84 ~]# oc rsh sf-csi-pod-demo-lun1-0 
sh-4.2$ df -hT | grep data
/dev/demo-lun1          xfs      100G   33M  100G   1% /data
sh-4.2$
sh-4.2$ dd if=/dev/urandom of=/data/file1 bs=1M count=1024 oflag=direct,nonblock status=progress
951058432 bytes (951 MB) copied, 8.035793 s, 118 MB/s
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 9.01663 s, 119 MB/s
sh-4.2$ dd if=/dev/urandom of=/data/file2 bs=1M count=1024 oflag=direct,nonblock status=progress
969932800 bytes (970 MB) copied, 8.041331 s, 121 MB/s
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 8.88998 s, 121 MB/s
sh-4.2$ dd if=/dev/urandom of=/data/file3 bs=1M count=1024 oflag=direct,nonblock status=progress
963641344 bytes (964 MB) copied, 8.036069 s, 120 MB/s
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 8.92353 s, 120 MB/s
sh-4.2$ 
sh-4.2$ md5sum /data/file* > /data/md5.md5
sh-4.2$
sh-4.2$ cat /data/md5.md5 
1a11a28242d3066f9e784399c658ea7f  /data/file1
f3094ce3ad294ed14a6a4e7a58b0fd87  /data/file2
4caeaa71c83d9fc770c70d686ebbe61d  /data/file3
sh-4.2$
sh-4.2$ exit
exit
[root@node84 ~]#
[root@node84 ~]# oc delete -f demo-lun1-sc-pvc-app.yaml
storageclass.storage.k8s.io "sf-csi-sc-demo-lun1" deleted
persistentvolumeclaim "sf-csi-pvc-demo-lun1" deleted
statefulset.apps "sf-csi-pod-demo-lun1" deleted
[root@node84 ~]#

# 修改 storageclass 和 pvc 中的容量大小 
[root@node84 ~]# oc apply -f demo-lun1-sc-pvc-app.yaml
storageclass.storage.k8s.io/sf-csi-sc-demo-lun1 created
persistentvolumeclaim/sf-csi-pvc-demo-lun1 created
statefulset.apps/sf-csi-pod-demo-lun1 created
[root@node84 ~]# 
[root@node84 ~]# oc get pvc
NAME                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
sf-csi-pvc-demo-lun1   Bound     pvc-f9e173a4-7d55-11ea-bd22-000c29a12090   120Gi      RWO            sf-csi-sc-demo-lun1   27s
[root@node84 ~]#
[root@node84 ~]# oc rsh sf-csi-pod-demo-lun1-0 
sh-4.2$ df -hT | grep data
/dev/demo-lun1          xfs      120G  3.5G  117G   3% /data
sh-4.2$ ls /data/
file1  file2  file3  md5.md5  test
sh-4.2$ 
sh-4.2$ md5sum -c /data/md5.md5 
/data/file1: OK
/data/file2: OK
/data/file3: OK
sh-4.2$ exit
exit
[root@node84 ~]#
```

