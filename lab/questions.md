# Practice Questions

Use `kubectl` to complete the following tasks. Run `grade` when finished.

## Task 1: Deployment
Create namespace `app-team`, then create a deployment named `web` in that namespace using image `nginx:1.27` with exactly `2` replicas.

## Task 2: Service
Expose the `app-team/web` deployment with a ClusterIP service named `web-svc` on port `80` targeting port `80`.

## Task 3: ConfigMap mount
In namespace `lab`, create a ConfigMap named `app-config` with key `message` and value `cka-practice`. Create a pod named `config-reader` using image `busybox:1.36` that sleeps for one hour and mounts the ConfigMap at `/etc/config`.

## Task 4: NetworkPolicy
In namespace `restricted`, create a NetworkPolicy named `allow-lab-client` that selects pods with label `app=backend` and allows ingress only from pods with label `access=allowed` in namespaces with label `kubernetes.io/metadata.name=lab`.

## Task 5: Storage
In namespace `storage`, create a PersistentVolumeClaim named `data` requesting `1Gi` with access mode `ReadWriteOnce`.
