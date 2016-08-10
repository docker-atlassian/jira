#!/bin/bash
#set -x
# Install Atlassian Jira
## Install Java
# Add Oracle Java PPA
apt-get -y update
apt-get -y install software-properties-common
add-apt-repository -y ppa:webupd8team/java
apt-get -y update
# Auto-accept the Oracle License
echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
apt-get -y install libpq-dev oracle-java8-installer

# Add the Jira cookbook
echo "cookbook 'jira', git: 'https://github.com/proppen/jira'" >> /Berksfile ; /opt/chef/embedded/bin/berks vendor /etc/chef/cookbooks/

# Here we make any changes to postgresql for Jira, see cookbook documentation for examples.
sed -i "s%md5sumhash%$(echo -n 'dbpassword' | openssl md5 | sed -e 's/.* /md5/')%g" /etc/chef/node.json
/etc/init.d/postgresql start ; chef-solo ; /etc/init.d/postgresql stop

## Now Install Atlassian Jira
sh /opt/atlassian-$AppName-$AppVer-$Arch.bin -q -varfile /opt/response.varfile

# Clean up
rm -f /var/cache/oracle-jdk8-installer/jdk-*.tar.gz
rm -f /opt/atlassian-$AppName-$AppVer-$Arch.bin
