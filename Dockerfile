FROM dockerfile/nodejs:latest

# Install Git
RUN apt-get install -y git

# Add source
ADD ./node_modules /opt/zorium-seed/node_modules
ADD . /opt/zorium-seed

WORKDIR /opt/zorium-seed

# Install app deps
RUN npm install

CMD ["npm", "start"]
