#!/bin/bash

# Define Docker Hub username
DOCKERHUB_USERNAME="nyetes"

# Install Docker
install_docker() {
    echo "Installing Docker..."
    # Update package index
    sudo apt-get update

    # Install packages to allow apt to use a repository over HTTPS
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Set up the stable Docker repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Update package index again
    sudo apt-get update

    # Install Docker CE
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Verify Docker installation
    sudo docker --version
}

# Clone GitHub repository
clone_repository() {
    echo "Cloning GitHub repository..."
    git clone https://github.com/silarhi/php-hello-world.git
}

# Create Dockerfile for Apache and Nginx
create_dockerfile() {
    echo "Creating Dockerfile..."
    echo "# Use the official PHP image with Apache" > Dockerfile
    echo "FROM php:7.4-apache" >> Dockerfile
    echo "" >> Dockerfile
    echo "# Copy the contents of the php-hello-world directory into the container's web server directory" >> Dockerfile
    echo "COPY . /var/www/html" >> Dockerfile
    echo "" >> Dockerfile
    echo "# Set the ServerName directive to suppress Apache warnings" >> Dockerfile
    echo "RUN echo \"ServerName localhost\" >> /etc/apache2/apache2.conf" >> Dockerfile
    echo "" >> Dockerfile
    echo "RUN apt-get update && apt-get install -y nginx \\" >> Dockerfile
    echo "    && rm -rf /var/lib/apt/lists/* \\" >> Dockerfile
    echo "    && echo \"daemon off;\" >> /etc/nginx/nginx.conf \\" >> Dockerfile
    echo "    && rm /etc/nginx/sites-enabled/default" >> Dockerfile
    echo "" >> Dockerfile
    echo "EXPOSE 80" >> Dockerfile
    echo "" >> Dockerfile
    echo "CMD service apache2 start && nginx" >> Dockerfile
}

# Build Docker image
build_image() {
    echo "Building Docker image..."
    docker build -t php-hello-world .
}

# Push Docker image to Docker Hub
push_image() {
    echo "Pushing Docker image to Docker Hub..."
    # Log in to Docker Hub
    docker login -u "$DOCKERHUB_USERNAME"
    
    # Tag Docker image
    docker tag php-hello-world "$DOCKERHUB_USERNAME/php-hello-world"
    
    # Push Docker image to Docker Hub
    docker push "$DOCKERHUB_USERNAME/php-hello-world"
}

# Main function
main() {
    install_docker
    clone_repository
    cd php-hello-world || exit
    
    create_dockerfile
    
    build_image
    push_image
}

# Run the main function
main