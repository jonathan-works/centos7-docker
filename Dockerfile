# Use a imagem base do CentOS 7 para a arquitetura aarch64
FROM arm64v8/centos:7

# Ajuste os repositórios para usar o vault.centos.org
RUN sed -i 's/mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's/#baseurl=/baseurl=/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's/mirror.centos.org/vault.centos.org/g' /etc/yum.repos.d/CentOS-*.repo

# Atualize os pacotes, instale o Java OpenJDK, o Apache HTTP Server e o unzip
RUN yum -y update && \
    yum -y install \
    epel-release \
    yum-utils \
    java-1.8.0-openjdk \
    httpd \
    unzip \
    && yum-config-manager --enable epel \
    && yum -y install \
    vim \
    curl \
    wget \
    git \
    && yum clean all

# Defina o diretório de trabalho
WORKDIR /app

# Copie a pasta jboss-eap-6.4 da raiz do contexto de build para o contêiner
COPY ./jboss-eap-6.4 /opt/jboss6

# Ajuste as permissões do diretório JBoss
RUN chown -R root:root /opt/jboss6 && chmod -R 755 /opt/jboss6

# Defina variáveis de ambiente para o JBoss
ENV JBOSS_HOME /opt/jboss6
ENV PATH $PATH:$JBOSS_HOME/bin
ENV JAVA_OPTS="-Xms1572m -Xmx1572m -XX:+UseCompressedOops -XX:+AggressiveOpts -XX:+UseG1GC -XX:MaxGCPauseMillis=400 -Djava.net.preferIPv4Stack=true -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000 -Djboss.jvmRoute=node1"

# Defina o comando padrão para iniciar o JBoss com as opções de JVM configuradas
CMD ["standalone.sh", "--debug", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
