# Database Load Balancing


## Introduction
This repository contains scripts that would enable you minimally setup your deployment to Amazon Web Services by just running a couple of commands.



### Technology and Platforms Used

- [Packer](https://www.packer.io/docs/index.html) 
- [Terraform](https://www.terraform.io/docs/index.html)
- [AWS](aws.amazon.com)
- [HAPROXY](https://www.haproxy.org/)


### How to Build Amazon Machine Images (AMI) for your deployment

In the root directory, you would see a folder called `packer`, that is where the `json` file packer would use to create the machine image is.

In order to create a machine image on AWS, please do the following:
- export the AWS_ACCESS_KEY, AWS_SECRET_KEY & AWS_REGION in your terminal like this
  - `export AWS_ACCESS_KEY=<paste your aws access keys here>`
  - `export AWS_SECRET_KEY=<paste your secret keys here>`
  - `export AWS_REGION=<paste your region here i.e. eu-west-1>`

- After exporting the variables above, run the command `packer build packer_templates/master_temp.json` to begin the master image build process and run `packer build packer_templates/slave_temp.json` to build the slave
  - After running the command you'll see the build flow on your terminal and you can also check your `AWS EC2 console` 
The `packer build` commands above would build two  `Amazon Machine Image`s where in the `master` database is configured with the script `db_config/master_script.sh` and the slave database is created with the script `db_config/slave_script.sh`.
  - **Note** that before you run the `packer` command above, ensure that you have AWS `Elastic IP` generated first and then associated with the `Master DB server` after launching the instance, there after in the `db_config/slave_script` file change `-h < ELastic IP `  to the `Master DB server` Elastic IP.
  Also, in the `db_config/pg_hba.conf` file, in the `replication` section where you would see these values `host     replication     replicauser     54.76.225.227/24        md5`, please leave the IP address section empty in or change it to `all`.



### How To Launch AMIs With Terraform.
To launch AMI machine images on AWS do the following 
- Depending on whether you intend to launch `Master | Slave` AMIs, change directory into the `db_config/terraform_< master | slave >` folder by running this command `cd db_config/terraform_< master | slave >` from your terminal
- In the `db_config_terraform_< master | slave >` directory, run the command `terraform init` 
- Before running any other terraform commands, you should export these value `export AWS_AMI_ID=<AMI ID generated at the end of the packer build>`, `AWS_SECRET_KEY=<AWS SECRET KEY>`, `AWS_ACCESS_KEY=<AWS ACCESS KEY>`, `AWS_REGION=<AWS REGION>`, `MASTER_IP=<ELASTIC IP FOR MASTER>`, `SLAVE1_IP=<ELASTIC IP FOR SLAVE1>`,`SLAVE2_IP=<ELASTIC IP FOR SLAVE2>`in the terminal.
- After initialising the directory, 
    - For the `master DB` 
    run the command `terraform plan -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" -var="region=${AWS_REGION}" -var="ami_image_id=${PACKER_IMG}" -var="master_eip=${MASTER_IP}" -auto-approve` after the packer image has been build
    - After running `terraform plan` above, run the command `terraform apply -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" -var="region=${AWS_REGION}" -var="ami_image_id=${PACKER_IMG}" -var="master_eip=${MASTER_IP}" -auto-approve` to begin the process of launching the instance.
   - For the `slave DB` 
    - **NOTE**. Same process above applies to the slave instances but the command to run is `terraform apply -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" -var="region=${AWS_REGION}"  -var="ami_image_id=${PACKER_IMG}"  -var="slave1_eip=${SLAVE1_IP}" -var="slave2_eip=${SLAVE2_IP}" -auto-approve`


