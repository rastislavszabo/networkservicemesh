apiVersion: v1
kind: Service
metadata:
  name: skydive-analyzer
  namespace: {{ .Release.Namespace }}
  labels:
    app: skydive-analyzer
spec:
  type: {{ .Values.monSvcType }}
  ports:
    - port: 8082
      name: api
    - port: 8082
      name: protobuf
      protocol: UDP
    - port: 12379
      name: etcd
    - port: 12380
      name: etcd-cluster
  selector:
    app: skydive
    tier: analyzer
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: skydive-analyzer-config-file
  namespace: {{ .Release.Namespace }}
data:
  skydive.yml: |
    storage:
      mymemory:
        driver: memory

    logging:
      level: DEBUG

    agent:
      topology:
        probes:
          - runc

    analyzer:
      listen: 0.0.0.0:8082
      topology:
        probes:
          - nsm
        backend: mymemory
      flow:
        backend: mymemory

    etcd:
      data_dir: /tmp/skydive/etcd
      listen: 0.0.0.0:12379

    ui:
      topology:
        favorites:
          nsm-filter: "G.V().Has('Type', 'netns').Descendants().As('namespaces').G.V().Has('Type', 'host').As('hosts').Select('namespaces', 'hosts')"
          nsm-filter-secure-intranet-connectivity: "G.V().Has('Type', 'netns').Descendants().As('namespaces').G.V().Has('Type', 'host').As('hosts').Select('namespaces', 'hosts')"
          nsm-edges: "G.E().HasKey('NSM')"

        default_filter: "nsm-filter"
        default_highlight: "nsm-edges"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: skydive-analyzer
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    matchLabels:
      app: skydive
      tier: analyzer
  replicas: 1
  template:
    metadata:
      labels:
        app: skydive
        tier: analyzer
    spec:
      serviceAccount: nsmgr-acc
      containers:
        - name: skydive-analyzer
          image: {{ .Values.image }}
          imagePullPolicy: {{ .Values.pullPolicy }}
          args:
            - analyzer
          ports:
            - containerPort: 8082
            - containerPort: 8082
              protocol: UDP
            - containerPort: 12379
            - containerPort: 12380
          livenessProbe:
            httpGet:
              port: 8082
              path: /api/status
            initialDelaySeconds: 60
            periodSeconds: 10
            failureThreshold: 3
          volumeMounts:
            - mountPath: /etc/skydive.yml
              subPath: skydive.yml
              name: skydive-analyzer-config-file
            - name: spire-agent-socket
              mountPath: /run/spire/sockets
              readOnly: true
      volumes:
        - name: skydive-analyzer-config-file
          configMap:
            name: skydive-analyzer-config-file
        - name: spire-agent-socket
          hostPath:
            path: /run/spire/sockets
            type: DirectoryOrCreate

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: skydive-agent-config-file
  namespace: {{ .Release.Namespace }}
data:
  skydive.yml: |
    logging:
      level: DEBUG

    agent:
      topology:
        probes:
          - runc

      docker:
        netns:
          run_path: /var/run/netns

      runc:
        run_path:
        - /var/run/containerd/runc

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: skydive-agent
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    matchLabels:
      app: skydive
      tier: agent
  template:
    metadata:
      labels:
        app: skydive
        tier: agent
    spec:
      hostNetwork: true
      hostPID: true
      containers:
        - name: skydive-agent
          image: {{ .Values.image }}
          imagePullPolicy: {{ .Values.pullPolicy }}
          args:
            - agent
          ports:
            - containerPort: 8081
          env:
            - name: SKYDIVE_ANALYZERS
              value: "$(SKYDIVE_ANALYZER_SERVICE_HOST):$(SKYDIVE_ANALYZER_SERVICE_PORT_API)"
          securityContext:
            privileged: true
          volumeMounts:
            - name: docker
              mountPath: /var/run/docker.sock
            - name: run
              mountPath: /var/run/netns
              mountPropagation: HostToContainer
            - name: runc
              mountPath: /var/run/containerd/runc
            - name: skydive-agent-config-file
              mountPath: /etc/skydive.yml
              subPath: skydive.yml
            - name: spire-agent-socket
              mountPath: /run/spire/sockets
              readOnly: true
      volumes:
        - name: docker
          hostPath:
            path: /var/run/docker.sock
        - name: run
          hostPath:
            path: /var/run/netns
        - name: runc
          hostPath:
            path: /var/run/containerd/runc
        - name: skydive-agent-config-file
          configMap:
            name: skydive-agent-config-file
        - name: spire-agent-socket
          hostPath:
            path: /run/spire/sockets
            type: DirectoryOrCreate
