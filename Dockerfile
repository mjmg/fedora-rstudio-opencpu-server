FROM mjmg/fedora-r-base:latest

RUN \ 
  dnf install -y 'dnf-command(builddep)' rpmdevtools make R-devel httpd-devel libapreq2-devel libcurl-devel protobuf-devel openssl-devel && \
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/rapache-1.2.7-2.1.src.rpm && \ 
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/opencpu-1.6.2-7.1.src.rpm && \ 
  dnf builddep -y --nogpgcheck rapache-1.2.7-2.1.src.rpm && \
  dnf builddep -y --nogpgcheck opencpu-1.6.2-7.1.src.rpm 

RUN \
  useradd -ms /bin/bash builder && \
  chmod o+r rapache-1.2.7-2.1.src.rpm && \
  chmod o+r opencpu-1.6.2-7.1.src.rpm && \
  mv rapache-1.2.7-2.1.src.rpm /home/builder/ && \
  mv opencpu-1.6.2-7.1.src.rpm /home/builder/ 

USER builder

RUN \
  rpmdev-setuptree

RUN \
  cd ~ && \
  rpm -ivh rapache-1.2.7-2.1.src.rpm && \
  rpmbuild -ba ~/rpmbuild/SPECS/rapache.spec

RUN \
  cd ~ && \
  rpm -ivh opencpu-1.6.2-7.1.src.rpm && \
  rpmbuild -ba ~/rpmbuild/SPECS/opencpu.spec

USER root

RUN \
  dnf install -y MTA mod_ssl /usr/sbin/semanage && \
  cd /home/builder/rpmbuild/RPMS/x86_64/ && \
  rpm -ivh rapache-*.rpm && \
  rpm -ivh opencpu-lib-*.rpm && \
  rpm -ivh opencpu-server-*.rpm

RUN \
  wget https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-server-rhel-1.0.44-x86_64.rpm && \
  dnf install -y --nogpgcheck rstudio-server-rhel-1.0.44-x86_64.rpm 

# Cleanup
RUN \
  rm -rf /home/builder/* && \
  userdel builder && \
  dnf autoremove -y
  
RUN \
  useradd rstudio && \
  echo "rstudio:rstudio" | chpasswd  
  
# Apache ports
EXPOSE 80
EXPOSE 443
EXPOSE 8004
EXPOSE 9001

ADD \
  rstudio-server.conf /etc/supervisor/conf.d/rstudio-server.conf
ADD \
  opencpu.conf /etc/supervisor/conf.d/opencpu.conf 
ADD \  
  supervisor-server.conf /etc/supervisor/conf.d/supervisor-server.conf
  
# Define default command.
CMD ["/usr/bin/supervisord","-c","/etc/supervisor.conf"]
