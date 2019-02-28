#!/usr/bin/env bash

# little script to setup an service account with privileges
# using GOOGLE_APPLICATION_CREDENTIALS and GOOGLE_PROJECT as env vars

gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

gcloud iam service-accounts keys create ${GOOGLE_APPLICATION_CREDENTIALS} \
  --iam-account terraform@${GOOGLE_PROJECT}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT} \
  --member serviceAccount:terraform@${GOOGLE_PROJECT}.iam.gserviceaccount.com \
  --role roles/editor

gcloud services enable \
  container.googleapis.com \
  containerregistry.googleapis.com
