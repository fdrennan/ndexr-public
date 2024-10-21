FROM rocker/verse:4.4

# Setting Working Directory
WORKDIR /root
RUN mkdir renv .ssh


# Update and install system dependencies
RUN apt update -qq -y


RUN apt install -y libxml2-dev zlib1g-dev libpq-dev libtiff5-dev libjpeg-dev libpng-dev
RUN apt install -y libssl-dev libssh2-1-dev libcurl4-openssl-dev libsodium-dev libsasl2-dev libssh-dev
RUN apt install -y software-properties-common dirmngr make git-core cmake python3-pip  python3.10-venv
RUN apt install -y r-base r-base-dev python3-pip libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev net-tools dnsutils
RUN apt clean && \
    rm -rf /var/lib/apt/lists/*

# AWS CLI Installation
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm awscliv2.zip

COPY .renvignore .renvignore

# Install 'renv' R package and configure R settings
RUN R -e "install.packages('renv')"
RUN echo "options(docker=TRUE)" >> /root/.Rprofile
RUN echo "source('onload/activate.r')" >> /root/.Rprofile
RUN echo "Sys.setenv(RETICULATE_PYTHON='/usr/bin/python3')" >> /root/.Rprofile

# Copy necessary files for R environment
COPY renv.lock renv/settings.dcf renv/settings.json requirements.txt ./
COPY onload onload

RUN apt remove libnode-dev -y
RUN curl -sL https://deb.nodesource.com/setup_20.x  | bash -
RUN apt -y install nodejs


# Activate renv and restore R packages
RUN R -e "renv::activate()"
RUN R -e "renv::restore()"
RUN echo "IP_ADDRESS=$(dig @resolver4.opendns.com myip.opendns.com +short)" >> /root/.Renviron

RUN pip install -r requirements.txt

COPY ./package.json ./

RUN npm i

# Copying source and configuration files
COPY src src
COPY app.r app.r

