---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/faveo-helpdesk-k8s/
redirect_from:
  - /theme-setup/
last_modified_at: 2024-09-17
toc: true
---
# Deploying Faveo Helpdesk on managed Kubernetes Cluster <!-- omit in toc -->
<img src="https://support.faveohelpdesk.com/uploads/2021/kubernetes-logo.png" alt="drawing" width="300"/>

# Introduction

In this article, we’ll be deploying Faveo Helpdesk app on top of Kubernetes. But first, you may be wondering why we’re using Kubernetes and Docker for the deployment of our Faveo Helpdesk application. Kubernetes allows us to derive maximum utility from containers and build cloud-native applications that can run anywhere, independent of cloud-specific requirements. With Kubernetes, we can automatically deploy, scale, and manage our application. We will go through the steps one by one required in deploying Faveo Helpdesk app.

# Prerequisites

* A Managed Kubernetes 1.28+ cluster with your connection configuration set as the kubectl default on the local machine from which you access the cluster. You can read more about installing kubectl in the [official documentation](https://kubernetes.io/docs/tasks/tools/).
* The Helm 3 package manager installed on your local machine. You can follow the [official guide here](https://helm.sh/docs/intro/install/) to install Helm 3.
* A Managed Mysql 8.0+ or MariaDB 10.6+ database in the same region as of the Cluster.
* A Managed Redis database in the same region as of the Cluster.
* Spaces bucket in the same region.
  (We recommend to have all this requirements in the same region as of the cluster for better performance and good connectivity among them)
* A fully registered domain name with an available A record.You can use the domain registrar of your choice. Don’t worry about associating your domain’s A record with an IP at this time. Once you deploy Nginx ingress controller and your Load balancer is attached to your cluster, you will connect your_domain to the proper IP.
 
Before beginning the installation take a look at the simplified Architectural Diagram of Faveo Helpdesk on kubernetes. This will help you understand the different components used and how they are inter connected to make Faveo Helpdesk work.
<img src="https://support.faveohelpdesk.com/uploads/2021/faveo-kubernetes.png">

Note: Digital Ocean allows you to install some of the resources or addons via one-click installers. But we recommend to follow the steps in this guide, which uses the Offcial documentaion of that addons to install them, as you will have complete control over there versions.

## Step 1: Configuring and Deploying Faveo Helpdesk
In this step, you’ll create a Kubernetes object description file, also known as a manifest, for a deployment. This manifest will contain all of the configuration details needed to deploy your Faveo app to your cluster.

First, you’ll need a directory to store all your YAML configuration files. Create a new directory of your choice and create and open deploy-faveo.yml. Add the below configurations, making sure to replace <mark>order-no</mark> and <mark>license-key</mark> with your order number and license in the CURL Api. Leave the commented lines as it is. The reason for commenting certain lines here will be explained later in Step 6.
```sh
apiVersion: v1
kind: Service
metadata:
  name: faveo-svc
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: faveo-pods
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: faveo-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: faveo-pods
  template:
    metadata:
      labels:
        app: faveo-pods
    spec:
      containers:
      - name: faveo-apache
        image: ladybird/faveo-k8s-apache2
        resources:
          limits:
            memory: 700Mi
            cpu: 1
          requests:
            memory: 600Mi
            cpu: 800m
        livenessProbe:
          httpGet:
            path: /probe.php
            port: 80
          initialDelaySeconds: 5
          timeoutSeconds: 5
          periodSeconds: 10
          failureThreshold: 1
        readinessProbe:
          httpGet:
            path: /probe.php
            port: 80
          initialDelaySeconds: 5
          timeoutSeconds: 5
          periodSeconds: 10
          failureThreshold: 1
        volumeMounts:
        - name: volume-data
          mountPath: /var/www/html
#        - name: cm
#          mountPath: /var/www/html/.env
#          subPath: .env
      initContainers:
      - name: fetch
        image: ladybird/faveo-fetcher
        command: ['sh','-c','apt update;apt install git -y; curl https://store.faveohelpdesk.com/download/faveo\?order_number\=85070569\&serial_key\=5HINJHDGDIBK0000 --output faveo.zip; unzip faveo.zip -d html;chown -R www-data:www-data /html']
        volumeMounts:
        - name: volume-data
          mountPath: /html
      volumes:
      - name: volume-data
        emptyDir: {}
#      - name: cm
#        configMap:
#          name: faveo-env
```
Save and close the file.

Next, apply your new deployment with the following command:
```sh
kubectl apply -f deploy-faveo.yml
```
This will create a service and deployment for Faveo helpdesk pods.You can confirm by executing below commands.
```sh
kubectl get pods
```
```sh
kubectl get svc
```

Now that we have the Faveo app running but it is still not accessible externally. For this we need to route the external traffic to faveo-svc service which we created by applying deploy-faveo.yml to the cluster.

You’ve created deployment of the Faveo helpdesk app with accompanying Service.In the next step, you’ll install the Nginx Ingress Controller which will enable external traffic to route to appropriate backed service.

## Step 2: Configuring Nginx Ingress Controller

The Nginx Ingress Controller consists of a Pod and a Service. The Pod runs the Controller, which constantly polls the /ingresses endpoint on the API server of your cluster for updates to available Ingress Resources. The Service is of type LoadBalancer, the cluster will automatically create a Load Balancer on your cloud provider, through which all external traffic will flow to the Controller. The Controller will then route the traffic to appropriate Services, as defined in Ingress Resources.

Only the LoadBalancer Service knows the IP address of the automatically created Load Balancer. To install the Nginx Ingress Controller to your cluster, you’ll first need to add its repository to Helm by running:
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
Update your local Helm chart repository cache:
```sh
helm repo update
```
Create a namespace for Ingress Nginx:
```sh
kubectl create ns ingress-nginx
```
Finally, run the following command to install the Nginx ingress:

```sh
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=ingress-nginx
```
The above command installs the Nginx Ingress Controller from the stable charts repository and deploys a LoadBalancer. You can watch the LoadBalancer become availble by running. 
```sh
kubectl --namespace ingress-nginx get services -o wide -w ingress-nginx-controller
```
At this point once the External IP is availble copy that and set the A record for your domain in your registrar.

You’ve installed the Nginx Ingress maintained by the Kubernetes community. It will route HTTP and HTTPS traffic from the Load Balancer to appropriate back-end Services, configured in Ingress Resources. In the next step, you’ll expose the Faveo Helpdesk app deployments using an Ingress Resource.

## Step 3: Exposing the App Using an Ingress
Now you’re going to create an Ingress Resource and use it to expose the Faveo helpdesk app deployments at your desired domains. You’ll then test it by accessing it from your browser.

You’ll store the Ingress in a file named ingress.yml. Create it using your editor. Add the following lines to your file:
```sh
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: faveo-ingress
    namespace: default

spec:
   rules:
    - host: "your_domain_name"
      http:
        paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: faveo-svc
               port:
                 number: 80

```
Make sure to replace <mark>your_domain_name</mark> . Save and close the file.

Create it in Kubernetes by running the following command:
```sh
kubectl apply -f ingress.yml
```

Next, you’ll need to ensure that your domain is pointed to the Load Balancer via A records. This is done in your domain registrar. Once your domain name is fully propagated to the Loadbalancer IP. You can visit your Faveo helpdesk app  from browser using http://==your_domain_name== .

You’ve created and configured an Ingress Resource to serve the Faveo Helpdesk app deployments at your domain. In the next step, you’ll set up Cert-Manager, so you’ll be able to secure your Ingress Resources with free TLS certificates from Let’s Encrypt.

## Step 4: Securing the Ingress Using Cert-Manager

To secure your Ingress Resources, you’ll install Cert-Manager, create a ClusterIssuer for production, and modify the configuration of your Ingress to take advantage of the TLS certificates. ClusterIssuers are Cert-Manager Resources in Kubernetes that provision TLS certificates for the whole cluster. Once installed and configured, your app will be running behind HTTPS.

Add the Jetstack Helm repository:
```sh
helm repo add jetstack https://charts.jetstack.io
```
Update your local Helm chart repository cache:
```sh
helm repo update
```
Install cert-manager and its Custom Resource Definitions (CRDs) like Issuers and ClusterIssuers
```sh
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.8.0 \
  --set installCRDs=true
```
To verify our installation, check the cert-manager Namespace for running pods:
```sh
kubectl get pods --namespace cert-manager
```
You’ll now create one that issues Let’s Encrypt certificates, and you’ll store its configuration in a file named cluster_issuer.yaml. Create it and open it for editing.

Add the following lines:
```sh
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # Email address used for ACME registration
    email: your_email_address
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Name of a secret used to store the ACME account private key
      name: letsencrypt-prod
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
```
This configuration defines a ClusterIssuer that contacts Let’s Encrypt in order to issue certificates. You’ll need to replace your_email_address with your email address in order to receive possible urgent notices regarding the security and expiration of your certificates.

Save and close the file.

Roll it out with kubectl:
```sh
kubectl apply -f cluster_issuer.yml
```
With Cert-Manager installed, you’re ready to introduce the certificates to the Ingress Resource defined in the previous step. Open ingress.yml for editing.
Update it with the below code:
```sh
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: letsencrypt-prod
    name: faveo-ingress
    namespace: default

spec:
   tls:
   - hosts:
     - your_domain_name
     secretName: faveo-tls
   rules:
    - host: your_domain_name
      http:
        paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: faveo-svc
               port:
                 number: 80

```

Remember to replace the <mark>your_domain_name</mark> with your own domain. When you’ve finished editing, save and close the file.

Re-apply this configuration to your cluster by running the following command:
```sh
kubectl apply -f ingress.yml
```
You’ll need to wait a few minutes for the Let’s Encrypt servers to issue a certificate for your domains. In the meantime, you can track its progress by inspecting the output of the following command:
```sh
kubectl get certificate
```
From the output of the above command the READY field must be True. Navigate to your domain in your browser to test. You’ll find the padlock to the left of the address bar in your browser, signifying that your connection is secure.

In this step, you have installed Cert-Manager using Helm and created a Let’s Encrypt ClusterIssuer. After, you updated your Ingress Resource to take advantage of the Issuer for generating TLS certificates. In the end, you have confirmed that HTTPS works correctly by navigating to your domain in your browser.

## Step 5: Faveo Helpdesk Web UI installtion

At this point if the domain name is propagated properly with your server’s IP you can open Faveo in browser just by entering your domainname. You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/k8s-gui) Wizard

## Step 6: Creating and Configuring ConfigMap for .env

After completing Step 4 you have generated .env file under the faveo root directory. Faveo Helpdesk is laravel based Web Application which solely relies on .env file for functionality. The .env file stores all the sensitive information such as Database credentials, Redis, S3 etc which is later used by the code base. 

If you take a look at deploy-faveo.yml which you created in Step 1, the replicas and part of volume definitions will be commented out. So creating that deploy-faveo.yml manifest will result in creating only one pod which contains the Faveo code base where we generated the .env file after completing the Step 5.

ConfigMaps allow us to keep configurations separate from application images. Such separation is useful when other alternatives are not a good fit. ConfigMap takes a configuration from a source and mounts it into running containers as a volume. This was we can achieve the configuration of the .env file to be shared across multiple pods and nodes. We are literally achieving persistent volume.

After injecting configmap as volume, we can achieve multiple replicas of pods, auto scalling of pods.

First let's retrive the content of .env by getting inside the running container. Execute the below command to get the pod name.
```sh
kubectl get pod
```
Copy and replace the pod name from the previous output
```sh
kubectl exec -ti your_pod_name -- bash
```
This is will give you access to the bash shell inside the container.
Use cat or nano to get the content of the .env file.
```sh
cat .env
```
or
```sh
nano .env
```
Copy those values and save it somewhere on you machine to be used later.

Now, create a file named configmap.yml. Add the following lines and place all the content of .env you copied previously under ".env: |" section.
```sh
apiVersion: v1
kind: ConfigMap
metadata:
  name: faveo-env
data:
  .env: |
    ***** Replace you content here *******
    .................
    DB_ENGINE=MyISAM
    MAIL_DRIVER=smtp
    MAIL_HOST=mailtrap.io
    MAIL_PORT=2525
    MAIL_USERNAME=null
    MAIL_PASSWORD=null
    CACHE_DRIVER=redis
    SESSION_DRIVER=file
    SESSION_COOKIE_NAME=faveo_8079
    QUEUE_DRIVER=sync
    FCM_SERVER_KEY=AIzaSyBJNRvyub-_-DnOAiIJfuNOYMnffO2sfw4
    FCM_SENDER_ID=505298756081
    ........................
    ........................

    ****************************************

```
Make sure you replaced all the content of your .env under the ".env |".
Roll it out with kubectl:
```sh
kubectl apply -f configmap.yml
```
Verfify its running:
```sh
kubectl get cm
```
Now, Let's modify the deployment to mount configmap inside and also lets increase the number of replicas.
Open deploy-faveo.yml and uncomment all the commented lines. It should now look like this.
```sh
apiVersion: v1
kind: Service
metadata:
  name: faveo-svc
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: faveo-pods
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: faveo-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: faveo-pods
  template:
    metadata:
      labels:
        app: faveo-pods
    spec:
      containers:
      - name: faveo-apache
        image: ladybird/faveo-k8s-apache2
        resources:
          limits:
            memory: 700Mi
            cpu: 1
          requests:
            memory: 600Mi
            cpu: 800m
        livenessProbe:
          httpGet:
            path: /probe.php
            port: 80
          initialDelaySeconds: 5
          timeoutSeconds: 5
          periodSeconds: 10
          failureThreshold: 1
        readinessProbe:
          httpGet:
            path: /probe.php
            port: 80
          initialDelaySeconds: 5
          timeoutSeconds: 5
          periodSeconds: 10
          failureThreshold: 1
        volumeMounts:
        - name: volume-data
          mountPath: /var/www/html
        - name: cm
          mountPath: /var/www/html/.env
          subPath: .env
      initContainers:
      - name: fetch
        image: ladybird/faveo-fetcher
        command: ['sh','-c','apt update;apt install git -y; curl https://store.faveohelpdesk.com/download/faveo\?order_number\=85070569\&serial_key\=5HINJHDGDIBK0000 --output faveo.zip; unzip faveo.zip -d html;chown -R www-data:www-data /html']
        volumeMounts:
        - name: volume-data
          mountPath: /html
      volumes:
      - name: volume-data
        emptyDir: {}
      - name: cm
        configMap:
          name: faveo-env
```
Save and close the file.
Lets inject this updated definition to kube api:
```sh
kubectl apply -f deploy-faveo.yml
```
Now the single pod which was running before will be terminating and new 3 pods will be created with updated definition. You can give your desired number of replicas.
You can also use Horizontal Pod scaling along with metrics server for autoscaling and descaling.
Verify the new pods running by executing the below command:
```sh
kubectl get pods
```
Now that you have created a configmap out of .env and configured it in the deployment which will mount the .env inside all the pods that it creates.
The configmap not only will be used by faveo deployment pods but aslo by the supervisor deployment which you will create in next step.

## Step 7: Configuring and Deploying Supervisor

Faveo Helpdesk requires certain set of command to be executed to have the Emails sending/receiving, reports generating and recurring. To achieve this we will be spinng a supervisor pod with .env mounted inside it via configmap, which then does the job or us.

Create and open file suprevisor.yml and copy the following lines inside it. Make sure to replace <mark>order-no</mark> and <mark>license-key</mark> with your order number and license in the CURL Api.
```sh
apiVersion: apps/v1
kind: Deployment
metadata:
  name: supervior-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: supervisor-pods
  template:
    metadata:
      labels:
        app: supervisor-pods
    spec:
      containers:
      - name: faveo-supervisor
        image: ladybird/faveo-k8s-supervisor
        resources:
          limits:
            memory: 1024Mi
            cpu: 1
          requests:
            memory: 900Mi
            cpu: 900m
        volumeMounts:
        - name: volume-data
          mountPath: /var/www/html
        - name: cm
          mountPath: /var/www/html/.env
          subPath: .env
      initContainers:
      - name: fetch
        image: ladybird/faveo-fetcher
       command: ['sh','-c','apt update;apt install git -y; curl https://store.faveohelpdesk.com/download/faveo\?order_number\=order-no\&serial_key\=license-key --output faveo.zip; unzip faveo.zip -d html;chown -R www-data:www-data /html']
        volumeMounts:
        - name: volume-data
          mountPath: /html
      volumes:
      - name: volume-data
        emptyDir: {}
      - name: cm
        configMap:
          name: faveo-env
```
Save and close the file.

Next, apply your new deployment with the following command:
```sh
kubetctl apply -f deploy-faveo.yml
```
This will create a supervisor deployment .You can confirm by executing below commands.
```sh
kubectl get pods
```
Now you should see supervisor pod running along with Faveo Helpdesk pods.

The supervisor pod will use the configuration from .env which is mounted via configmap to perform all the operations.
Always keep the number of supervisor replicas to 1 increasing this will lead unnecessary overlapping of mails and



