FROM dockerfile/nodejs:latest

# Install Git
RUN apt-get install -y git

# Add source
ADD ./node_modules /opt/app/node_modules
ADD . /opt/app

WORKDIR /opt/app

# Install app deps
RUN npm install

CMD ["npm", "start"]
