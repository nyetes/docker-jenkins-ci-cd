#!/bin/bash

DOCKERHUB_USERNAME="nyetes"


install_docker() {
    echo "Installing Docker..."
    
    sudo apt-get update

   
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

   
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

   
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

   
    sudo apt-get update

    
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    sudo docker --version
}

clone_repository() {
    echo "Cloning GitHub repository..."
    git clone https://github.com/silarhi/php-hello-world.git
}


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


build_image() {
    echo "Building Docker image..."
    docker build -t php-hello-world .
}


push_image() {
    echo "Pushing Docker image to Docker Hub..."
   
    docker login -u "$DOCKERHUB_USERNAME"
    
   
    docker tag php-hello-world "$DOCKERHUB_USERNAME/php-hello-world"
    
    
    docker push "$DOCKERHUB_USERNAME/php-hello-world"
}


main() {
    install_docker
    clone_repository
    cd php-hello-world || exit
    
    create_dockerfile
    
    build_image
    push_image
}


main