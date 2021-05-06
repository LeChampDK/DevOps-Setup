FROM jenkins/jenkins

USER root

RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list

# Write RUN-statements here, that will install the required software within the Jenkins container
# Install dotnet 5
RUN apt-get install -y gpg
RUN wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o microsoft.asc.gpg
RUN mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/prod.list
RUN mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list
RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN apt-get update
RUN apt-get install -y dotnet-sdk-5.0

# Install Node
RUN curl -fsSL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install -y nodejs

# Install Angular
RUN npm install -g @angular/cli

# Install sqlpackage
RUN apt-get install libunwind8
RUN wget -O sqlpackage.zip https://go.microsoft.com/fwlink/?linkid=2157202
RUN unzip sqlpackage.zip -d /opt/sqlpackage
RUN chmod a+x /opt/sqlpackage/sqlpackage
ENV PATH="/opt/sqlpackage:${PATH}"

# Install SSDT
COPY ssdt /opt/ssdt

# Install Docker
RUN apt-get update && apt-get install -y apt-transport-https \
       ca-certificates curl gnupg2 \
       software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce-cli
RUN groupadd docker
RUN usermod -aG docker jenkins

# The file must end with this statement to make sure that Jenkins runs with the right user permission.
USER jenkins