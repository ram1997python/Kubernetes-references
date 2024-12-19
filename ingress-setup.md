Example of Kubernetes Ingress Configuration
Below is a practical example demonstrating how to use Ingress to route traffic to different Services in a Kubernetes cluster. This setup simulates an online store with three Services: BookService, VideoService, and GameService.

Prerequisites:
Ensure an Ingress Controller (e.g., NGINX Ingress Controller) is installed in your cluster.

For ingress setup - https://medium.com/@dikkumburage/how-to-install-nginx-ingress-controller-93a375e8edde

1. Services and Deployments
BookService Deployment and Service
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: book-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: books
  template:
    metadata:
      labels:
        app: books
    spec:
      containers:
      - name: book-app
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: book-service
spec:
  selector:
    app: books
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

```
VideoService Deployment and Service
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: video-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: videos
  template:
    metadata:
      labels:
        app: videos
    spec:
      containers:
      - name: video-app
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: video-service
spec:
  selector:
    app: videos
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

```
GameService Deployment and Service
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: game-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: games
  template:
    metadata:
      labels:
        app: games
    spec:
      containers:
      - name: game-app
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: game-service
spec:
  selector:
    app: games
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

```
2. Ingress Configuration
This Ingress routes traffic based on URL paths.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: store-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: store.com
    http:
      paths:
      - path: /books
        pathType: Prefix
        backend:
          service:
            name: book-service
            port:
              number: 80
      - path: /videos
        pathType: Prefix
        backend:
          service:
            name: video-service
            port:
              number: 80
      - path: /games
        pathType: Prefix
        backend:
          service:
            name: game-service
            port:
              number: 80

```

3. How it Works
Access URLs:
http://store.com/books → Routes to BookService.
http://store.com/videos → Routes to VideoService.
http://store.com/games → Routes to GameService.
Notes:
Replace store.com with your domain name and configure DNS to point to your Ingress Controller's IP.
The rewrite-target annotation ensures that requests maintain proper path structure.
This example demonstrates a simple Ingress setup to manage external access for different services.

