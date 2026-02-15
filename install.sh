GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/10] Refreshing package lists...${NC}"
sudo apt update

echo -e "${GREEN}[2/10] Upgrading installed packages...${NC}"
sudo apt upgrade -y

echo -e "${GREEN}[3/10] Installing dependencies for Docker APT repo...${NC}"
sudo apt install -y ca-certificates curl gnupg lsb-release

echo -e "${GREEN}[4/10] Creating APT keyrings directory...${NC}"
sudo mkdir -p /etc/apt/keyrings

echo -e "${GREEN}[5/10] Downloading Docker GPG key...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo -e "${GREEN}[6/10] Adding Docker official APT repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "${GREEN}[7/10] Refreshing package lists (Docker packages)...${NC}"
sudo apt update

echo -e "${GREEN}[8/10] Installing Docker Engine, CLI, containerd, buildx, and Compose plugin...${NC}"
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "${GREEN}[9/10] Enabling and starting Docker...${NC}"
sudo systemctl enable docker
sudo systemctl start docker

echo -e "${GREEN}[10/10] Verifying Docker and Compose...${NC}"
docker --version
docker compose version

echo -e "${GREEN}Adding current user to docker group...${NC}"
sudo usermod -aG docker $USER

echo -e "${GREEN}Applying new group (log out and back in if docker still requires sudo)...${NC}"
newgrp docker
