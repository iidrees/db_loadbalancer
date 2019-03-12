#!/usr/bin/env bash

set -ex
set -o pipefail



# Build packer image
function build_master_image {
  printf "<<<<<<<<<<<<<<<<<<<<<<<<< Building Master_DB Packer Image >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
  if [[ $(ls *.txt) ]]; then
    rm *.txt
  fi
  rm -rf db_config/terraform_master/.terraform
  rm -rf db_config/terraform_slave/.terraform
  rm -rf load_balancer/terraform_haproxy/.terraform

  ls -ahl
  
  packer build packer_templates/master_temp.json | tee master_text.txt

  printf "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< AMI Build Done >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

# Build packer image
function build_slave_image {
  cd ../../
  rm -rf db_config/terraform_master/.terraform
  rm -rf db_config/terraform_slave/.terraform
  rm -rf load_balancer/terraform_haproxy/.terraform
  printf "<<<<<<<<<<<<<<<<<<<<<<<<< Building Slave_DB Packer Image >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  if [[ $(ls *.txt) ]]; then
    rm *.txt
  fi

  ls -ahl
  
  packer build packer_templates/slave_temp.json | tee slave_text.txt

  printf "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< AMI Build Done >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

# Build packer image
function build_haproxy_image {
  printf "<<<<<<<<<<<<<<<<<<<<<<<<< Building HAProxy Packer Image >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

  cd ../../
  rm -rf db_config/terraform_master/.terraform
  rm -rf db_config/terraform_slave/.terraform
  rm -rf load_balancer/terraform_haproxy/.terraform
  if [[ $(ls *.txt) ]]; then
    rm *.txt
  fi

  ls -ahl
  
  packer build packer_templates/haproxy_temp.json | tee haproxy_text.txt

  printf "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< AMI Build Done >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n"
}

# Run terraform deployment
function deploy_to_aws {
  printf "<<<<<<<<<<<<<<<<<<<<<< Start Terraform Deployment >>>>>>>>>>>>>>>>>>>>>>>>>>>> \n"

  PACKER_TXT=$(ls | grep .txt)
  PACKER_IMG=$(egrep -oe 'ami-.{17}' $PACKER_TXT |tail -n1)
  echo "PACKER_IMG=${PACKER_IMG}" >> .env
  
  

  if [ $PACKER_TXT == 'master_text.txt' ]; then

    cd db_setup/terraform_master/

    terraform init

    terraform apply -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" \
    -var="region=${AWS_REGION}"  -var="ami_image_id=${PACKER_IMG}" -var="master_eip=${MASTER_IP}" \
    -auto-approve
    printf "<<<<<<<<<<<<<<<<<<<<<<<<< Terraform Deployment Done >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n"
  elif [ $PACKER_TXT == 'slave_text.txt' ]; then

    cd db_setup/terraform_slave/
    
    terraform init

    terraform apply -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" \
    -var="region=${AWS_REGION}"  -var="ami_image_id=${PACKER_IMG}"  -var="slave1_eip=${SLAVE1_IP}" \
    -var="slave2_eip=${SLAVE2_IP}" -auto-approve
    printf "<<<<<<<<<<<<<<<<<<<<<<<<< Terraform Deployment Done >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n"
  else
    
    cd load_balancer/terraform_haproxy
    
    terraform init

    terraform apply -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" \
    -var="region=${AWS_REGION}"  -var="ami_image_id=${PACKER_IMG}" -var="haproxy_eip=${HAPROXY_IP}" -auto-approve
    printf "<<<<<<<<<<<<<<<<<<<<<<<<< Terraform Deployment Done >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  fi;

  
}

function main {
  build_master_image
  deploy_to_aws
  build_slave_image
  deploy_to_aws
  build_haproxy_image
  deploy_to_aws
}

main