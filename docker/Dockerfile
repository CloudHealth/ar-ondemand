FROM 297322132092.dkr.ecr.us-east-1.amazonaws.com/cloudpercept/app:ubuntu18-base

USER root

COPY --chown=cloudhealth:cloudhealth . /home/cloudhealth/ar-ondemand

USER cloudhealth
WORKDIR /home/cloudhealth/ar-ondemand

RUN /bin/bash -c -l "bundle --version"
RUN /bin/bash -c -l "RAILS_ENV=test BUNDLE_GEMFILE=rails_3.2.Gemfile bundle install --no-deployment --binstubs=bin"
