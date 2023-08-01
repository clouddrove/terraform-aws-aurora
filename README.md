<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS Aurora
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module which creates RDS Aurora database resources on AWS and can create different type of databases. Currently it supports Postgres and MySQL.
     </p>

<p align="center">

<a href="https://github.com/clouddrove/terraform-aws-aurora/releases/latest">
  <img src="https://img.shields.io/github/release/clouddrove/terraform-aws-aurora.svg" alt="Latest Release">
</a>
<a href="https://github.com/clouddrove/terraform-aws-aurora/actions/workflows/tfsec.yml">
  <img src="https://github.com/clouddrove/terraform-aws-aurora/actions/workflows/tfsec.yml/badge.svg" alt="tfsec">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-APACHE-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-aws-aurora'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AWS+Aurora&url=https://github.com/clouddrove/terraform-aws-aurora'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AWS+Aurora&url=https://github.com/clouddrove/terraform-aws-aurora'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 






## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-aurora/releases).


Here are some examples of how you can use this module in your inventory structure:

### Aurora MySQL
```hcl
  module "aurora" {
    source                          = "clouddrove/aurora/aws"
    version                         = "1.3.0"

    name                            = "backend"
    environment                     = "test"
    label_order                     = ["name", "environment"]
    username                        = "admin"
    database_name                   = "dt"
    engine                          = "aurora-mysql"
    engine_version                  = "5.7.12"
    subnets                         = "subnet-xxxxxxxxx"
    aws_security_group              = [sg-xxxxxxxxxxx]
    replica_count                   = 1
    instance_type                   = "db.t2.small"
    apply_immediately               = true
    skip_final_snapshot             = true
    publicly_accessible             = false
  }
```
### Aurora Postgres
```hcl
    module "postgres" {
      source              = "clouddrove/aurora/aws"
      version             = "1.3.0"
      name                = "backend"
      environment         = "test"
      label_order         = ["name", "environment"]

      username            = "root"
      database_name       = "test_db"
      engine              = "aurora-postgresql"
      engine_version      = "9.6.9"
      subnets             = "subnet-xxxxxxxxx"
      aws_security_group  = [sg-xxxxxxxxxxx]
      replica_count       = 1
      instance_type       = "db.r4.large"
      apply_immediately   = true
      skip_final_snapshot = true
      publicly_accessible = false
    }
```
### Aurora Serverless MySQL
```hcl
  module "aurora" {
    source                          = "clouddrove/aurora/aws"
    version                         = "1.3.0"
    name                            = "aurora-mysql-serverless"
    environment                     = "test"
    label_order                     = ["name", "environment"]
    serverless_enabled              = true
    min_capacity                    = 1
    max_capacity                    = 4
    username                        = "root"
    database_name                   = "test_db"
    engine                          = "aurora"
    engine_version                  = "5.6.10a"
    kms_key_id                      = module.kms_key.key_arn
    subnets                         = "subnet-xxxxxxxxx"
    aws_security_group              = [sg-xxxxxxxxxxx]
    apply_immediately               = true
    skip_final_snapshot             = true
    availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  }
```
### Aurora Serverless Postgres
```hcl
    module "postgres" {
      source                          = "clouddrove/aurora/aws"
      version                         = "1.3.0"
      name                            = "aurora-Postgres"
      environment                     = "test"
      label_order                     = ["name", "environment"]
      enable                          = true
      serverless_enabled              = true
      min_capacity                    = 2
      max_capacity                    = 4
      username                        = "root"
      database_name                   = "test_db"
      engine                          = "aurora-postgresql"
      engine_version                  = "10.7"
      kms_key_id                      = module.kms_key.key_arn
      subnets                         = "subnet-xxxxxxxxx"
      aws_security_group              = [sg-xxxxxxxxxxx]
      apply_immediately               = true
      skip_final_snapshot             = true
      availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    }
```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alias | The display name of the alias. The name must start with the word `alias` followed by a forward slash. | `string` | `"alias/aurora"` | no |
| allowed\_ip | List of allowed ip. | `list(any)` | `[]` | no |
| allowed\_ports | List of allowed ingress ports | `list(any)` | `[]` | no |
| apply\_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window. | `bool` | `false` | no |
| auto\_minor\_version\_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window. | `bool` | `true` | no |
| backtrack\_window | The target backtrack window, in seconds. Only available for aurora engine currently.Must be between 0 and 259200 (72 hours) | `number` | `0` | no |
| backup\_retention\_period | How long to keep backups for (in days). | `number` | `7` | no |
| copy\_tags\_to\_snapshot | Copy all Cluster tags to snapshots. | `bool` | `true` | no |
| customer\_master\_key\_spec | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| database\_name | Name for an automatically created database on cluster creation. | `string` | `""` | no |
| deletion\_protection | If the DB instance should have deletion protection enabled. | `bool` | `false` | no |
| deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource. | `number` | `7` | no |
| egress\_rule | Enable to create egress rule | `bool` | `true` | no |
| enable | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| enable\_key\_rotation | Specifies whether key rotation is enabled. | `string` | `true` | no |
| enable\_security\_group | Enable default Security Group with only Egress traffic allowed. | `bool` | `true` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL). | `list(string)` | <pre>[<br>  "audit",<br>  "general"<br>]</pre> | no |
| enabled\_monitoring\_role | Create IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. | `bool` | `true` | no |
| enabled\_rds\_cluster | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| enabled\_subnet\_group | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| endpoints | Map of additional cluster endpoints and their attributes to be created | `any` | `{}` | no |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql. | `string` | `"aurora-mysql"` | no |
| engine\_mode | The database engine mode. | `string` | `"serverless"` | no |
| engine\_version | Aurora database engine version. | `string` | `"5.6.10a"` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| final\_snapshot\_identifier\_prefix | The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | `string` | `"final"` | no |
| iam\_database\_authentication\_enabled | Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported. | `bool` | `true` | no |
| instance\_type | Instance type to use. | `string` | `""` | no |
| is\_enabled | Specifies whether the key is enabled. | `bool` | `true` | no |
| is\_external | enable to udated existing security Group | `bool` | `false` | no |
| key\_usage | Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| kms\_description | The description of the key as viewed in AWS console. | `string` | `"Parameter Store KMS master key"` | no |
| kms\_key\_enabled | Specifies whether the kms is enabled or disabled. | `bool` | `true` | no |
| kms\_key\_id | The ARN for the KMS encryption key if one is set to the cluster. | `string` | `""` | no |
| kms\_multi\_region | Indicates whether the KMS key is a multi-Region (true) or regional (false) key. | `bool` | `false` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| monitoring\_interval | The interval (seconds) between points when Enhanced Monitoring metrics are collected. | `number` | `5` | no |
| monitoring\_role\_description | Description of the monitoring IAM role | `string` | `null` | no |
| monitoring\_role\_name | Name of the IAM role which will be created when create\_monitoring\_role is enabled. | `string` | `"rds-monitoring-role"` | no |
| monitoring\_role\_permissions\_boundary | ARN of the policy that is used to set the permissions boundary for the monitoring IAM role | `string` | `null` | no |
| mysql\_family | The family of the DB parameter group. | `string` | `"aurora-mysql8.0"` | no |
| mysql\_family\_serverless | The family of the DB parameter group. | `string` | `"aurora5.6"` | no |
| mysql\_iam\_role\_tags | Additional tags for the mysql iam role | `map(any)` | `{}` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | n/a | yes |
| password | Master DB password. | `string` | `""` | no |
| performance\_insights\_enabled | Specifies whether Performance Insights is enabled or not. | `bool` | `true` | no |
| port | The port on which to accept connections. | `string` | `""` | no |
| postgresql\_family | The family of the DB parameter group. | `string` | `"aurora-postgresql13"` | no |
| postgresql\_family\_serverless | The family of the DB parameter group. | `string` | `"aurora-postgresql10"` | no |
| preferred\_backup\_window | When to perform DB backups. | `string` | `"02:00-03:00"` | no |
| preferred\_maintenance\_window | When to perform DB maintenance. | `string` | `"sun:05:00-sun:06:00"` | no |
| protocol | The protocol. If not icmp, tcp, udp, or all use the. | `string` | `"tcp"` | no |
| publicly\_accessible | Whether the DB should have a public IP address. | `bool` | `false` | no |
| replica\_count | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | `number` | `1` | no |
| replica\_scale\_enabled | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas. | `bool` | `false` | no |
| replica\_scale\_min | Minimum number of replicas to allow scaling. | `number` | `2` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-aurora"` | no |
| s3\_import | Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported) | `map(string)` | `null` | no |
| scaling\_configuration | Map of nested attributes with scaling properties. Only valid when engine\_mode is set to `serverless` | `map(string)` | `{}` | no |
| serverless\_enabled | Whether serverless is enabled or not. | `bool` | `false` | no |
| sg\_description | The security group description. | `string` | `"Instance default security group (only egress access is allowed)."` | no |
| sg\_egress\_description | Description of the egress and ingress rule | `string` | `"Description of the rule."` | no |
| sg\_egress\_ipv6\_description | Description of the egress\_ipv6 rule | `string` | `"Description of the rule."` | no |
| sg\_ids | of the security group id. | `list(any)` | `[]` | no |
| sg\_ingress\_description | Description of the ingress rule | `string` | `"Description of the ingress rule use elasticache."` | no |
| skip\_final\_snapshot | Should a final snapshot be created on cluster destroy. | `bool` | `false` | no |
| snapshot\_identifier | DB snapshot to create this database from. | `string` | `""` | no |
| ssm\_parameter\_description | SSM Parameters can be imported using. | `string` | `"Description of the parameter."` | no |
| ssm\_parameter\_endpoint\_enabled | Name of the parameter. | `bool` | `false` | no |
| ssm\_parameter\_type | Type of the parameter. | `string` | `"SecureString"` | no |
| storage\_encrypted | Specifies whether the underlying storage layer should be encrypted. | `bool` | `true` | no |
| subnets | List of subnet IDs to use. | `list(string)` | `[]` | no |
| username | Master DB username. | `string` | `""` | no |
| vpc\_id | The ID of the VPC that the instance security group belongs to. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | Amazon Resource Name (ARN) of cluster |
| rds\_cluster\_database\_name | Name for an automatically created database on cluster creation. |
| rds\_cluster\_endpoint | The cluster endpoint. |
| rds\_cluster\_id | The ID of the cluster. |
| rds\_cluster\_instance\_endpoints | A list of all cluster instance endpoints. |
| rds\_cluster\_master\_username | The master username. |
| rds\_cluster\_port | The port of Cluster. |
| rds\_cluster\_reader\_endpoint | The cluster reader endpoint. |
| serverless\_rds\_cluster\_master\_password | The master password. |
| tags | A mapping of tags to assign to the resource. |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-aws-aurora/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-aws-aurora)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
