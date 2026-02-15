# Refresh package lists
sudo apt update
# Upgrade all installed packages non-interactively
sudo apt upgrade -y
# Install dependencies for adding Docker’s APT repo
sudo apt install -y ca-certificates curl gnupg lsb-release
# Create directory for APT keyrings
sudo mkdir -p /etc/apt/keyrings
# Download Docker’s GPG key and save it for APT
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# Add Docker’s official APT repository for this Ubuntu release
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Refresh package lists again to include Docker packages
sudo apt update
# Install Docker Engine, CLI, containerd, buildx, and Compose plugin
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Start Docker on boot
sudo systemctl enable docker
# Start Docker now
sudo systemctl start docker
# Confirm Docker and Compose are installed
docker --version
docker compose version

# Add current user to docker group so you can run docker without sudo
sudo usermod -aG docker $USER
# Apply new group in this shell (or log out and back in)
newgrp docker