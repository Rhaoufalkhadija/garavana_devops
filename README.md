# Garavana — Infrastructure DevOps Complète

## Structure du projet

```
garavana/
├── flask-app/
│   ├── app.py                  # Application Flask + API + Dashboard
│   ├── test_app.py             # Tests pytest
│   ├── requirements.txt
│   ├── Dockerfile
│   └── templates/
│       └── dashboard.html      # Dashboard de monitoring
├── terraform/
│   ├── main.tf                 # EC2 + Security Group
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory.ini           # Inventaire des noeuds
│   ├── install_docker.yml
│   ├── install_k3s.yml
│   └── install_jenkins.yml
├── k8s/
│   ├── deployment.yml
│   └── service.yml
└── jenkins/
    └── Jenkinsfile             # Pipeline CI/CD
```

## Ordre de déploiement

### 1. Prérequis locaux
```bash
# Installer AWS CLI, Terraform, Ansible
aws configure   # entrer Access Key + Secret Key + region us-east-1
```

### 2. Terraform — créer les EC2
```bash
cd terraform/
terraform init
terraform plan -var="key_name=garavana-key"
terraform apply -var="key_name=garavana-key"
# Notez master_public_ip et worker_public_ip dans les outputs
```

### 3. Ansible — configurer les noeuds
```bash
cd ansible/
# Remplacer MASTER_IP et WORKER_IP dans inventory.ini

ansible-playbook -i inventory.ini install_docker.yml
ansible-playbook -i inventory.ini install_k3s.yml
ansible-playbook -i inventory.ini install_jenkins.yml
```

### 4. Kubernetes — déployer l'app
```bash
# Sur le master (SSH)
# Remplacer VOTRE_DOCKERHUB dans k8s/deployment.yml

kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
kubectl get pods
kubectl get svc
```

### 5. Jenkins — configurer le pipeline
1. Aller sur http://MASTER_IP:8080
2. Entrer le mot de passe initial (affiché par Ansible)
3. Installer les plugins : Git, Docker Pipeline, Pipeline
4. Créer les credentials Docker Hub (id: `dockerhub-creds`)
5. Créer un nouveau Pipeline → pointer vers ce dépôt
6. Configurer le webhook GitHub → http://MASTER_IP:8080/github-webhook/

## URLs d'accès
- Dashboard Garavana : http://WORKER_IP:30080/dashboard
- API Health         : http://WORKER_IP:30080/health
- API Metrics        : http://WORKER_IP:30080/api/metrics
- Jenkins            : http://MASTER_IP:8080

## Commandes utiles
```bash
# Etat du cluster
kubectl get nodes
kubectl get pods -A
kubectl get svc

# Logs de l'app
kubectl logs -l app=flask-app

# Rollback si problème
kubectl rollout undo deployment/flask-app

# Libérer les ressources AWS (important pour le tier gratuit)
terraform destroy -var="key_name=garavana-key"
```
# test webhook
