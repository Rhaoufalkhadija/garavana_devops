#!/bin/bash
# ============================================================
#  deploy.sh — Script de déploiement complet Garavana
#  Usage : ./deploy.sh <KEY_NAME> <DOCKERHUB_USER>
# ============================================================

set -e

KEY_NAME=${1:-"garavana-key"}
DOCKERHUB_USER=${2:-"VOTRE_DOCKERHUB"}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERR]${NC} $1"; exit 1; }

echo ""
echo "  ██████╗  █████╗ ██████╗  █████╗ ██╗   ██╗ █████╗ ███╗  ██╗ █████╗ "
echo "  ██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗ ██║██╔══██╗"
echo "  ██║  ███╗███████║██████╔╝███████║██║   ██║███████║██╔██╗██║███████║"
echo "  ██║   ██║██╔══██║██╔══██╗██╔══██║╚██╗ ██╔╝██╔══██║██║╚████║██╔══██║"
echo "  ╚██████╔╝██║  ██║██║  ██║██║  ██║ ╚████╔╝ ██║  ██║██║ ╚███║██║  ██║"
echo "   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚══╝╚═╝  ╚═╝"
echo ""
log "Démarrage du déploiement Garavana..."
log "Key pair   : $KEY_NAME"
log "Docker Hub : $DOCKERHUB_USER"
echo ""

# ── Étape 1 : Terraform ──────────────────────────────────────────────────────
log "ÉTAPE 1/5 — Provisionnement AWS avec Terraform..."
cd terraform/

if [ ! -f terraform.tfvars ]; then
    cat > terraform.tfvars <<EOF
aws_region = "us-east-1"
key_name   = "$KEY_NAME"
ami_id     = "ami-0c02fb55956c7d316"
EOF
fi

terraform init -input=false
terraform plan -var="key_name=$KEY_NAME" -out=tfplan
terraform apply -input=false tfplan

MASTER_IP=$(terraform output -raw master_public_ip)
WORKER_IP=$(terraform output -raw worker_public_ip)
ok "Master IP : $MASTER_IP"
ok "Worker IP : $WORKER_IP"
cd ..

# ── Étape 2 : Mettre à jour l'inventaire Ansible ─────────────────────────────
log "ÉTAPE 2/5 — Mise à jour de l'inventaire Ansible..."
sed -i "s/MASTER_IP/$MASTER_IP/" ansible/inventory.ini
sed -i "s/WORKER_IP/$WORKER_IP/" ansible/inventory.ini
ok "Inventaire mis à jour."

# Attendre que les EC2 soient accessibles
log "Attente que les EC2 soient prêtes (30s)..."
sleep 30

# ── Étape 3 : Ansible — Docker + k3s + Jenkins ───────────────────────────────
log "ÉTAPE 3/5 — Installation Docker, k3s et Jenkins via Ansible..."
cd ansible/

ansible-playbook -i inventory.ini install_docker.yml
ok "Docker installé."

ansible-playbook -i inventory.ini install_k3s.yml
ok "Cluster k3s prêt."

ansible-playbook -i inventory.ini install_jenkins.yml
ok "Jenkins installé."
cd ..

# ── Étape 4 : Kubernetes — déployer l'app ────────────────────────────────────
log "ÉTAPE 4/5 — Déploiement de l'application sur Kubernetes..."
sed -i "s/VOTRE_DOCKERHUB/$DOCKERHUB_USER/" k8s/deployment.yml

cd ansible/
ansible-playbook -i inventory.ini deploy_app.yml \
    -e "dockerhub_user=$DOCKERHUB_USER"
cd ..
ok "Application déployée."

# ── Étape 5 : Résumé ─────────────────────────────────────────────────────────
log "ÉTAPE 5/5 — Déploiement terminé."
echo ""
echo "=============================================="
echo -e "${GREEN}  Garavana déployé avec succès !${NC}"
echo "=============================================="
echo ""
echo -e "  Dashboard   : ${BLUE}http://$WORKER_IP:30080/dashboard${NC}"
echo -e "  API Health  : ${BLUE}http://$WORKER_IP:30080/health${NC}"
echo -e "  Jenkins     : ${BLUE}http://$MASTER_IP:8080${NC}"
echo ""
warn "N'oubliez pas d'arrêter vos EC2 quand vous ne travaillez pas !"
warn "  terraform destroy -var='key_name=$KEY_NAME'"
echo ""
