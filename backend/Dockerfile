FROM node:20

RUN apt-get update && apt-get install -y \
    build-essential \
    esbuild

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it

COPY src /app/src

COPY . .

EXPOSE 8000