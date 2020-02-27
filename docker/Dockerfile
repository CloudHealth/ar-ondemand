FROM 297322132092.dkr.ecr.us-east-1.amazonaws.com/cloudpercept/app:ubuntu18-base

USER root
# Setup access to github
RUN mkdir -p /home/cloudhealth/.ssh
ADD docker/config/ssh/config /home/cloudhealth/.ssh/config
RUN chmod 700 /home/cloudhealth/.ssh /home/cloudhealth/.ssh/* && chown -R cloudhealth:cloudhealth /home/cloudhealth/.ssh /home/cloudhealth/.ssh/*
ADD docker/config/ssh/id_rsa /home/cloudhealth/.ssh/id_rsa
RUN chown cloudhealth:cloudhealth /home/cloudhealth/.ssh/id_rsa && chmod 600 /home/cloudhealth/.ssh/id_rsa

COPY --chown=cloudhealth:cloudhealth . /home/cloudhealth/ar-ondemand

USER cloudhealth
WORKDIR /home/cloudhealth/ar-ondemand

RUN /bin/bash -c -l "bundle --version"
RUN /bin/bash -c -l "RAILS_ENV=test BUNDLE_GEMFILE=rails_3.2.Gemfile bundle install --no-deployment --binstubs=bin"

RUN rm /home/cloudhealth/.ssh/id_rsa
