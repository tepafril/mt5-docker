GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/14] Refreshing package lists...${NC}"
sudo apt update

echo -e "${GREEN}[2/14] Upgrading installed packages...${NC}"
sudo apt upgrade -y

echo -e "${GREEN}[3/14] Installing dependencies for Docker APT repo...${NC}"
sudo apt install -y ca-certificates curl gnupg lsb-release

echo -e "${GREEN}[4/14] Creating APT keyrings directory...${NC}"
sudo mkdir -p /etc/apt/keyrings

echo -e "${GREEN}[5/14] Downloading Docker GPG key...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo -e "${GREEN}[6/14] Adding Docker official APT repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "${GREEN}[7/14] Refreshing package lists (Docker packages)...${NC}"
sudo apt update

echo -e "${GREEN}[8/14] Installing Docker Engine, CLI, containerd, buildx, and Compose plugin...${NC}"
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "${GREEN}[9/14] Enabling and starting Docker...${NC}"
sudo systemctl enable docker
sudo systemctl start docker

echo -e "${GREEN}[10/14] Verifying Docker and Compose...${NC}"
docker --version
docker compose version

echo -e "${GREEN}[11/14] Adding current user to docker group...${NC}"
sudo usermod -aG docker $USER

echo -e "${GREEN}[12/14] Removing all containers, images, and volumes...${NC}"
docker compose down -v --rmi all

echo -e "${GREEN}[13/14] Pruning all build cache...${NC}"
docker builder prune -a -f

echo -e "${GREEN}[14/14] Applying new group (log out and back in if docker still requires sudo)...${NC}"
newgrp docker