FROM node:14

WORKDIR /app

# Copy the server files
COPY . .

# Install express
RUN npm install express

# Install openssl and generate a self-signed certificate
RUN apt-get update && \
    apt-get install -y openssl && \
    openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

# Start the server
CMD ["node", "server.js"]