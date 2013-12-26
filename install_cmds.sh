#!/bin/bash
set -x
# Install Atlassian Jira
## Install Java
# Add Oracle Java PPA
apt-get -y update
apt-get -y install python-software-properties
add-apt-repository -y ppa:webupd8team/java
apt-get -y update
# Auto-accept the Oracle License
echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
apt-get -y install libpq-dev oracle-java7-installer

# Add the Jira cookbook
echo "cookbook 'jira', git: 'https://github.com/proppen/jira'" >> /Berksfile ; /opt/chef/embedded/bin/berks install --path /etc/chef/cookbooks/

# Here we make any changes to postgresql for Jira, see cookbook documentation for examples.
./node.json /etc/chef/node.json
sed -i "s%md5sumhash%$(echo -n 'dbpassword' | openssl md5 | sed -e 's/.* /md5/')%g" /etc/chef/node.json
/etc/init.d/postgresql start ; chef-solo ; /etc/init.d/postgresql stop

## Now Install Atlassian Jira
# Unattended Jira install
sh /opt/atlassian-jira-6.1.5-x64.bin -q -varfile /opt/response.varfile
# Remove the file
rm -f /opt/atlassian-jira-6.1.5-x64.bin
