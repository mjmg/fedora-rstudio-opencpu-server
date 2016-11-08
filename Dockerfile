FROM mjmg/fedora-r-base:latest

RUN \ 
  dnf install -y 'dnf-command(builddep)' rpmdevtools
  
RUN \  
  #make R-devel httpd-devel libapreq2-devel libcurl-devel protobuf-devel openssl-devel  && \
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/rapache-1.2.7-2.1.src.rpm && \ 
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/opencpu-1.6.2-7.1.src.rpm 
  
RUN \  
  dnf builddep -y --nogpgcheck rapache-1.2.7-2.1.src.rpm opencpu-1.6.2-7.1.src.rpm 

RUN \
  useradd -ms /bin/bash builder && \
  chmod o+r rapache-1.2.7-2.1.src.rpm opencpu-1.6.2-7.1.src.rpm && \
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
#  dnf install -y MTA mod_ssl /usr/sbin/semanage && \
#  dnf install -y mod_ssl && \
  cd /home/builder/rpmbuild/RPMS/x86_64/ && \
  dnf install -y --nogpgcheck rapache-*.rpm opencpu-lib-*.rpm opencpu-server-*.rpm

RUN \
  wget https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-server-rhel-1.0.44-x86_64.rpm && \
  dnf install -y --nogpgcheck rstudio-server-rhel-1.0.44-x86_64.rpm 

# Cleanup
RUN \
  rm -rf /home/builder/* && \
  userdel builder && \
  dnf autoremove -y

# Add default rstudio user with pass rstudio
RUN \
  useradd rstudio && \
  echo "rstudio:rstudio" | chpasswd && \ 
  chmod -R +r /home/rstudio
  
# Ports
EXPOSE 80
EXPOSE 443
EXPOSE 8004
EXPOSE 9001

USER root

# Add supervisor conf files
ADD \
  rstudio-server.conf /etc/supervisor/conf.d/rstudio-server.conf
ADD \
  opencpu.conf /etc/supervisor/conf.d/opencpu.conf 

#install additional tools and library prerequisites for additional packages
RUN \
  dnf install -y libpng-devel libtiff-devel libjpeg-turbo-devel fftw-devel netcdf-devel \
    libxml2-devel cairo-devel libXt-devel NLopt-devel

# install additional packages
ADD \ 
  installpackages.sh /usr/local/bin/installpackages.sh
RUN \
  chmod +x /usr/local/bin/installpackages.sh && \
  /usr/local/bin/installpackages.sh
  
# Define default command.
CMD ["/usr/bin/supervisord","-c","/etc/supervisor.conf"]
