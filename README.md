Prerequisites Installs on local desktop:
1. Installed Chocolatey package manager for Windows:
   https://chocolatey.org/install
3. Installed k3d using Choco
4. Installed Docker Desktop
Hint: This may be required:

PS C:\WINDOWS\system32> bcdedit /set hypervisorlaunchtype auto
The operation completed successfully.

Installation and Setup:
1. Create Dockerfile and copy html (pre-created) to the same folder

2. Builder file and test
docker build -t bayo-nginx:v1 .

3. Create private registry
k3d registry create test-app-registry --port 5050

4. Create registries.yaml (file in folder)

mirrors:
"localhost:5050":
    endpoint:
      - http://k3d-test-app-registry:5050

5. Create new cluster with registy:

k3d cluster create seyicluster -p "9900:80@loadbalancer" --registry-use k3d-test-app-registry:5050 --registry-config registries.yaml

k3d node edit k3d-seyicluster-serverlb --port-add 80:80

Hint: Ran docker ps to see all port mappings with the load balancer

6. Tag and push the image to the local registry created

docker tag bayo-nginx:v1 localhost:5050/bayo-nginx:v1
docker push localhost:5050/bayo-nginx:v1

7. Create a new deployment and service using node port:

kubectl create ns bayodev

kubectl create deployment bayo-web-server-deployment --image=k3d-test-app-registry:5050/bayo-nginx:v1 -n bayodev

kubectl create service nodeport bayo-web-server-svc --tcp=80:80 -n bayodev

Note: Converted everything to attached .yaml files

Hint: To switch bayodev namespace as context: "kubectl config set-context --current --namespace=bayodev"

8. Create Ingress resource for service:

cat bayo-web-server-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bayo-web-server-ingress
  namespace: bayodev
spec:
  rules:
  - host: localhost
    http:
      paths:
      - backend:
          service:
            name: bayo-web-server-svc
            port:
              number: 80
        path: /
        pathType: Prefix

kubectl apply -f bayo-web-server-ingress.yaml
