FROM centos:7
MAINTAINER Chris Conner <chrism.conner@gmail.com>

USER root

RUN set -ex                           \
    && yum install -y epel-release \
    && yum update -y \
    && yum install epel-release -y \
    && yum update -y \
    && yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm \
    && yum install -y salt-cloud \
    && yum install -y python-pip \
    && /usr/bin/pip install pyvmomi \
    && yum install -y net-tools \
    && yum install -y bind-utils \
    && yum install -y iproute \
    && yum install -y vim \
    && yum install -y less \
    && yum install -y openssh \
    && yum install -y openssh-clients \
    && yum install -y wget \
    && yum install -y nginx \
    && yum clean -y expire-cache


#Install helm
RUN cd /tmp && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh && chmod 700 get_helm.sh && ./get_helm.sh

#Install kubectl
RUN echo -e '[kubernetes]\n\
name=Kubernetes\n\
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64\n\
enabled=1\n\
gpgcheck=1\n\
repo_gpgcheck=1\n\
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg\n\
'\
>> /etc/yum.repos.d/kubernetes.repo && yum install -y kubectl

#Install RKE
RUN cd /tmp && wget https://github.com/rancher/rke/releases/download/v0.1.11/rke_linux-amd64 && mv rke_linux-amd64 /usr/bin/rke && chmod 755 /usr/bin/rke

#Create extra HTML DIR
RUN mkdir -p /var/www
RUN chmod 777 /var/www

#Copy files
COPY nginx.conf /etc/nginx/nginx.conf

# volumes
VOLUME /etc/salt/cloud.maps.d \
       /etc/salt/cloud.profiles.d \
       /etc/salt/cloud.providers.d \
       /var/log/nginx \
       /etc/nginx/default.d \
       /etc/nginx/conf.d \
       /var/www

# ports
EXPOSE 5000/tcp

USER root

CMD [ "nginx" ]
