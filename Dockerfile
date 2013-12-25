# Install Atlassian Jira
# This is a trusted build based on the "base" image, but we also need postgresql
FROM linux/postgres

MAINTAINER Tom Eklöf tom@linux-konsult.com

## Install Java
# Add Oracle Java PPA
RUN apt-get -y update
RUN apt-get -y install python-software-properties
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get -y update
# Auto-accept the Oracle License
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
RUN apt-get -y install libpq-dev oracle-java7-installer

# Add the Jira cookbook
RUN echo "cookbook 'jira', git: 'https://github.com/proppen/jira'" >> /Berksfile ; /opt/chef/embedded/bin/berks install --path /etc/chef/cookbooks/

# Here we make any changes to postgresql for Jira, see cookbook documentation for examples.
ADD ./node.json /etc/chef/node.json
RUN sed -i "s%md5sumhash%$(echo -n 'dbpassword' | openssl md5 | sed -e 's/.* /md5/')%g" /etc/chef/node.json
RUN /etc/init.d/postgresql start ; chef-solo ; /etc/init.d/postgresql stop

## Now Install Atlassian Jira
# Fetch the Jira binary
ADD http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.1.5-x64.bin /opt/
# Fetch the unattended answer file
ADD ./response.varfile /opt/response.varfile
# Unattended Jira install
RUN sh /opt/atlassian-jira-6.1.5-x64.bin -q -varfile /opt/response.varfile
# Remove the file
RUN rm -f /opt/atlassian-jira-6.1.5-x64.bin

# Start the service
ADD ./postgres.sh /postgres.sh
ADD ./init.sh /init.sh
CMD ["sh", "/init.sh"]
EXPOSE 8080
