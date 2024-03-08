# Use latest nginx image as base image.
FROM nginx:latest

# Install wget and unzip
RUN apt-get update -y && \
    apt-get install wget -y && \
    apt-get install unzip -y


# Change Directory to the path that host nginx default website
WORKDIR /usr/share/nginx/html

# Download source code from a website
RUN wget https://www.free-css.com/assets/files/free-css-templates/download/page296/healet.zip


# Unzip folder
RUN unzip healet.zip

# Copy files into nginx html directory
RUN cp -r healet-html/. .

# Delete unwanted files
RUN rm -rf healet-html healet.zip

# Expose container port
EXPOSE 80
