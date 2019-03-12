# Database Load Balancing


## Introduction
This is a repository that contains scripts that would allow you to create a Postgresql database cluster of a Master and 2 Slaves, while leveraging on the database being replicated and load balanced with HAProxy for High Availabilty.



## Technology and Platforms Used

- [Packer](https://www.packer.io/docs/index.html) 
- [Terraform](https://www.terraform.io/docs/index.html)
- [AWS](aws.amazon.com)
- [HAProxy](https://www.haproxy.org/)


## How to Build Amazon Machine Images (AMI) for your deployment



In the root directory, you would see a folder called `packer`, that is where the `json` file packer would use to create the machine image is.


In order to create a machine image on AWS, please do the following:

  #### Databases

- export the AWS_ACCESS_KEY, AWS_SECRET_KEY & AWS_REGION in your terminal like this
  - `export AWS_ACCESS_KEY=<paste your aws access keys here>`
  - `export AWS_SECRET_KEY=<paste your secret keys here>`
  - `export AWS_REGION=<paste your region here i.e. eu-west-1>`

- After exporting the variables above, run the command `packer build packer_templates/master_temp.json` to begin the master image build process and run `packer build packer_templates/slave_temp.json` to build the slave
  - After running the command you'll see the build flow on your terminal and you can also check your `AWS EC2 console` 
The `packer build` commands above would build two  `Amazon Machine Image`s where in the `master` database is configured with the script `db_config/master_script.sh` and the slave database is created with the script `db_config/slave_script.sh`.
  - **Note** that before you run the `packer` command above, ensure that you have AWS `Elastic IP` generated first and then associated with the `Master DB server` after launching the instance, there after in the `db_config/slave_script` file change `-h < ELastic IP `  to the `Master DB server` Elastic IP.
  Also, in the `db_config/pg_hba.conf` file, in the `replication` section where you would see these values `host     replication     replicauser     54.76.225.227/24        md5`, please leave the IP address section empty in or change it to `all`.

#### HAProxy

In order to build the HAProxy AMI on AWS, do the following:


- Create 3 Elastic IP addresses for the MASTER and the 2 SLAVES EC2 instances on AWS
- open the file `haproxy.cfg` in the directory `load_balancer/haproxy.cfg` 
- in the `haproxy.cfg` 
  - in line 43 change `<MASTER ELASIC IP>` to one of the 3 Elastic IP addresses you get above
  - in line 44 change `<SLAVE_1 ELASIC IP>` to one of the remaining 2 Elastic IP addresses 
  - in line 45 change `<SLAVE_2 ELASIC IP>` to one of the last remaining Elastic IP address
- run the command `packer build packer_templates/haproxy_temp.json` to begin the HAProxy image build process



## Launch With Terraform.
To launch AMI machine images on AWS do the following 

  #### Databases

- Depending on whether you intend to launch `Master | Slave` AMIs, change directory into the `db_config/terraform_< master | slave >` folder by running this command `cd db_config/terraform_< master | slave >` from your terminal
- In the `db_config_terraform_< master | slave >` directory, run the command `terraform init` 
- Before running any other terraform commands, you should export these value `export AWS_AMI_ID=<AMI ID generated at the end of the packer build>`, `AWS_SECRET_KEY=<AWS SECRET KEY>`, `AWS_ACCESS_KEY=<AWS ACCESS KEY>`, `AWS_REGION=<AWS REGION>`, `MASTER_IP=<ELASTIC IP FOR MASTER>`, `SLAVE1_IP=<ELASTIC IP FOR SLAVE1>`,`SLAVE2_IP=<ELASTIC IP FOR SLAVE2>`in the terminal.
- After initialising the directory, 
    - For the `master DB` 
    run the command `terraform plan -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" -var="region=${AWS_REGION}" -var="ami_image_id=${PACKER_IMG}" -var="master_eip=${MASTER_IP}" -auto-approve` after the packer image has been build
    - After running `terraform plan` above, run the command `terraform apply -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" -var="region=${AWS_REGION}" -var="ami_image_id=${PACKER_IMG}" -var="master_eip=${MASTER_IP}" -auto-approve` to begin the process of launching the instance.
   - For the `slave DB` :
      - **NOTE**. Same process above applies to the slave instances but the command to run is `terraform apply -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" -var="region=${AWS_REGION}"  -var="ami_image_id=${PACKER_IMG}"  -var="slave1_eip=${SLAVE1_IP}" -var="slave2_eip=${SLAVE2_IP}" -auto-approve`



  #### HAProxy
- First create an Elastic IP on AWS for the HAProxy instance
- In the `load_balancer/terraform_haproxy` directory, run the command `terraform init` 
- Before running any other terraform commands, you should export these value `export AWS_AMI_ID=<AMI ID generated at the end of the packer build>`, `AWS_SECRET_KEY=<AWS SECRET KEY>`, `AWS_ACCESS_KEY=<AWS ACCESS KEY>`, `AWS_REGION=<AWS REGION>`, `HAPROXY_IP=<ELASTIC IP FOR HAPROXY>`in the terminal.

- change directory `cd load_balancer/terraform_haproxy`

- run the command `terraform plan -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" -var="region=${AWS_REGION}"  -var="ami_image_id=${PACKER_IMG}" -var="haproxy_eip=${HAPROXY_IP}" -auto-approve` after the packer image has been build
- After running `terraform plan` above, run the command `terraform apply -var="access_key=${AWS_ACCESS_KEY}" -var="secret_key=${AWS_SECRET_KEY}" -var="region=${AWS_REGION}" -var="ami_image_id=${PACKER_IMG}" -var="haproxy_eip=${HAPROXY_IP}" -auto-approve` to begin the process of launching the instance.


## How To Automate the Above Steps

In the root of the project, there is a `deploy.sh` script you can use to create both the `packer AMI` and deploy & launch the AMI created on AWS.

To run the script, ensure that you have all the necesary environment variables described above exported into the environment. Then run the command `./deploy.sh` and then watch the terminal to see how the deployment process runs.

## Check Load Balancer
After the instance is launched, go to this address to see the health check of the instances `<HAPROXY_IP:PORT>/admin?stats`
Login with the username: `admin1` , password: `AdMiN123`
