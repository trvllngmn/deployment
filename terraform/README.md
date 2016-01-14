# Terraform for a CoreOS etcd cluster

This directory contains a [Terraform](https://terraform.io) script to repeatably
create a [CoreOS](https://coreos.com/) etcd cluster.

It creates a VPC, Subnet, Internet Gateway, Routing Table linking the subnet to the gateway, a Security Group, and 3 EC2 instances in that subnet in an etcd cluster.

## Pre-reqs

* Terraform (brew install terraform)
* Curl (to get the cluster discovery token)
* AWS access keys

## Running

Firstly, create a file called terraform.tfvars with your access keys in it. These are used by Terraform when accessing AWS.

```bash
$ cat terraform.tfvars
aws_access_key = "<your_aws_access_key_here>"
aws_secret_key = "<your_aws_secret_key_here>"
```

If you're creating a new cluster from scratch, you'll need to get a new cluster token.

```bash
$ ./generate_etcd_cluster_token.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    58  100    58    0     0     60      0 --:--:-- --:--:-- --:--:--    60
Next steps: terraform plan
```

This copies the template file (etcd.yml.template) to etcd.yml.template and inserts the token into the discovery line.

Check the planned changes with

```bash
$ terraform plan
Refreshing Terraform state prior to plan...

   <... data snipped for brevity... >

Plan: 9 to add, 0 to change, 0 to destroy.
```

and then you can make them happen with

```bash
$ terraform apply
aws_vpc.coreos-vpc-tf: Creating...
  cidr_block:                "" => "172.20.0.0/16"

  <... output snipped for brevity ...>

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate
```

## Tear-down

```
$ terraform destroy
Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_vpc.coreos-vpc-tf: Refreshing state... (ID: vpc-965508f3)
aws_internet_gateway.coreos-vpc-gw-tf: Refreshing state... (ID: igw-3356c856)
aws_subnet.coreos-subnet-tf: Refreshing state... (ID: subnet-6774303e)
aws_security_group.coreos-tf: Refreshing state... (ID: sg-d66307b2)
aws_route_table.coreos-rt-tf: Refreshing state... (ID: rtb-f15c6294)
aws_route_table_association.coreos-rta-tf: Refreshing state... (ID: rtbassoc-c75b40a2)
aws_instance.coreos-tf-example.0: Refreshing state... (ID: i-514bd4dc)
aws_instance.coreos-tf-example.1: Refreshing state... (ID: i-564bd4db)
aws_instance.coreos-tf-example.2: Refreshing state... (ID: i-c44ad549)
aws_route_table_association.coreos-rta-tf: Destroying...
aws_instance.coreos-tf-example.1: Destroying...
aws_instance.coreos-tf-example.0: Destroying...
aws_instance.coreos-tf-example.2: Destroying...
aws_route_table_association.coreos-rta-tf: Destruction complete
aws_route_table.coreos-rt-tf: Destroying...
aws_route_table.coreos-rt-tf: Destruction complete
aws_internet_gateway.coreos-vpc-gw-tf: Destroying...
aws_internet_gateway.coreos-vpc-gw-tf: Destruction complete
aws_instance.coreos-tf-example.1: Destruction complete
aws_instance.coreos-tf-example.2: Destruction complete
aws_instance.coreos-tf-example.0: Destruction complete
aws_subnet.coreos-subnet-tf: Destroying...
aws_security_group.coreos-tf: Destroying...
aws_security_group.coreos-tf: Destruction complete
aws_subnet.coreos-subnet-tf: Destruction complete
aws_vpc.coreos-vpc-tf: Destroying...
aws_vpc.coreos-vpc-tf: Destruction complete

Apply complete! Resources: 0 added, 0 changed, 9 destroyed.
```

## Notes

The state file records all the things that Terraform created and knows about. Terraform [recommend that you place this into source control](https://www.terraform.io/intro/getting-started/build.html) to ensure everyone has the same copy.

Items created outside of Terraform (eg not registered in the tfstate file) will be ignored.