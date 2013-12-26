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

# Work around the omnibus pg gem issue as suggested by Joshua Timberman in COOK-1406
apt-get install -y build-essential
apt-get build-dep -y postgresql
cd /opt/chef/embedded/
curl -o postgresql-9.2.1.tar.gz http://ftp.postgresql.org/pub/source/v9.2.1/postgresql-9.2.1.tar.gz
tar xzf postgresql-9.2.1.tar.gz
rm -f postgresql-9.2.1.tar.gz
cd postgresql-9.2.1
export MAJOR_VER=9.2
./configure --prefix=/opt/chef/embedded --mandir=/opt/chef/embedded/share/postgresql/${MAJOR_VER}/man --docdir=/opt/chef/embedded/share/doc/postgresql-doc-${MAJOR_VER} --sysconfdir=/etc/postgresql-common --datarootdir=/opt/chef/embedded/share/ --datadir=/opt/chef/embedded/share/postgresql/${MAJOR_VER} --bindir=/opt/chef/embedded/lib/postgresql/${MAJOR_VER}/bin --libdir=/opt/chef/embedded/lib/ --libexecdir=/opt/chef/embedded/lib/postgresql/ --includedir=/opt/chef/embedded/include/postgresql/ --enable-integer-datetimes --enable-thread-safety --enable-debug --with-gnu-ld --with-pgport=5432 --with-openssl --with-libedit-preferred --with-includes=/opt/chef/embedded/include --with-libs=/opt/chef/embedded/lib
make
make install
/opt/chef/embedded/bin/gem install pg -- --with-pg-config=/opt/chef/embedded/lib/postgresql/9.2/bin/pg_config

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
