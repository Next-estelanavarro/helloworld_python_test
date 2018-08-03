FROM amazonlinux:latest

MAINTAINER Diego Garcia <diego.garcia@beeva.com>

RUN yum update -y -q && yum install -y libxslt-devel
RUN yum install -y curl python27 python27-devel python27-pip python27-libs build-essential libxml2-devel libffi-dev gcc \
    openssl libssl-dev git zip gzip wget

RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && ln -s /usr/local/bin/pip /usr/bin/pip
RUN pip install --upgrade pip && pip install -q virtualenv

RUN groupadd -g 497 jenkins && useradd -u 498 -g jenkins -s /bin/bash -d /home/jenkins jenkins \
&& mkdir -p /home/jenkins && chown -R jenkins:jenkins /home/jenkins && usermod -U jenkins

WORKDIR /home/jenkins
CMD ["bash"]
