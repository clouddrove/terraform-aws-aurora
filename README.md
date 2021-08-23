<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS Aurora
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module which creates RDS Aurora database resources on AWS and can create different type of databases. Currently it supports Postgres and MySQL.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/terraform-v0.15-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="Licence">
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

- [Terraform 0.15](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-aurora/releases).


Here are some examples of how you can use this module in your inventory structure:

### Aurora MySQL
```hcl
  module "aurora" {
    source                          = "clouddrove/aurora/aws"
    version                         = "0.15.0"

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
      version             = "0.15.0"
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
    version                         = "0.15.0"
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
      version                         = "0.15.0"
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
| apply\_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window. | `bool` | `false` | no |
| auto\_minor\_version\_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window. | `bool` | `true` | no |
| auto\_pause | Whether to enable automatic pause. A DB cluster can be paused only when it's idle (it has no connections). | `bool` | `false` | no |
| availability\_zone | The Availability Zone of the RDS instance. | `string` | `""` | no |
| availability\_zones | The Availability Zone of the RDS cluster. | `list(any)` | `[]` | no |
| aws\_security\_group | Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported. | `list(string)` | `[]` | no |
| backtrack\_window | The target backtrack window, in seconds. Only available for aurora engine currently.Must be between 0 and 259200 (72 hours) | `number` | `0` | no |
| backup\_retention\_period | How long to keep backups for (in days). | `number` | `7` | no |
| copy\_tags\_to\_snapshot | Copy all Cluster tags to snapshots. | `bool` | `true` | no |
| database\_name | Name for an automatically created database on cluster creation. | `string` | `""` | no |
| db\_cluster\_parameter\_group\_name | The name of a DB Cluster parameter group to use. | `string` | `"default.aurora5.6"` | no |
| db\_parameter\_group\_name | The name of a DB parameter group to use. | `string` | `"default.aurora5.6"` | no |
| deletion\_protection | If the DB instance should have deletion protection enabled. | `bool` | `false` | no |
| enable | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| enable\_http\_endpoint | Enable HTTP endpoint (data API). Only valid when engine\_mode is set to serverless. | `bool` | `true` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL). | `list(string)` | `[]` | no |
| enabled\_rds\_cluster | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| enabled\_subnet\_group | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql. | `string` | `"aurora-mysql"` | no |
| engine\_mode | The database engine mode. | `string` | `"serverless"` | no |
| engine\_version | Aurora database engine version. | `string` | `"5.6.10a"` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| final\_snapshot\_identifier\_prefix | The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | `string` | `"final"` | no |
| iam\_database\_authentication\_enabled | Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported. | `bool` | `true` | no |
| iam\_roles | A List of ARNs for the IAM roles to associate to the RDS Cluster. | `list(string)` | `[]` | no |
| identifier\_prefix | Prefix for cluster and instance identifier. | `string` | `""` | no |
| instance\_type | Instance type to use. | `string` | `""` | no |
| kms\_key\_id | The ARN for the KMS encryption key if one is set to the cluster. | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| max\_capacity | The maximum capacity. Valid capacity values are 1, 2, 4, 8, 16, 32, 64, 128, and 256. | `number` | `4` | no |
| min\_capacity | The minimum capacity. Valid capacity values are 1, 2, 4, 8, 16, 32, 64, 128, and 256. | `number` | `2` | no |
| monitoring\_interval | The interval (seconds) between points when Enhanced Monitoring metrics are collected. | `number` | `5` | no |
| mysql\_family | The family of the DB parameter group. | `string` | `"aurora-mysql5.7"` | no |
| mysql\_family\_serverless | The family of the DB parameter group. | `string` | `"aurora5.6"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | n/a | yes |
| password | Master DB password. | `string` | `""` | no |
| performance\_insights\_enabled | Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| performance\_insights\_kms\_key\_id | The ARN for the KMS key to encrypt Performance Insights data. | `string` | `""` | no |
| port | The port on which to accept connections. | `string` | `""` | no |
| postgresql\_family | The family of the DB parameter group. | `string` | `"aurora-postgresql9.6"` | no |
| postgresql\_family\_serverless | The family of the DB parameter group. | `string` | `"aurora-postgresql10"` | no |
| preferred\_backup\_window | When to perform DB backups. | `string` | `"02:00-03:00"` | no |
| preferred\_maintenance\_window | When to perform DB maintenance. | `string` | `"sun:05:00-sun:06:00"` | no |
| publicly\_accessible | Whether the DB should have a public IP address. | `bool` | `false` | no |
| replica\_count | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | `number` | `1` | no |
| replica\_scale\_cpu | CPU usage to trigger autoscaling. | `number` | `70` | no |
| replica\_scale\_enabled | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas. | `bool` | `false` | no |
| replica\_scale\_in\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale in. | `number` | `300` | no |
| replica\_scale\_max | Maximum number of replicas to allow scaling. | `number` | `0` | no |
| replica\_scale\_min | Minimum number of replicas to allow scaling. | `number` | `2` | no |
| replica\_scale\_out\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale out. | `number` | `300` | no |
| replication\_source\_identifier | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. | `string` | `""` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-aurora"` | no |
| s3\_import | Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported) | `map(string)` | `null` | no |
| scaling\_configuration | Map of nested attributes with scaling properties. Only valid when engine\_mode is set to `serverless` | `map(string)` | `{}` | no |
| seconds\_until\_auto\_pause | The time, in seconds, before an Aurora DB cluster in serverless mode is paused. Valid values are 300 through 86400. | `number` | `300` | no |
| serverless\_enabled | Whether serverless is enabled or not. | `bool` | `false` | no |
| skip\_final\_snapshot | Should a final snapshot be created on cluster destroy. | `bool` | `false` | no |
| snapshot\_identifier | DB snapshot to create this database from. | `string` | `""` | no |
| source\_region | The source region for an encrypted replica DB cluster. | `string` | `""` | no |
| storage\_encrypted | Specifies whether the underlying storage layer should be encrypted. | `bool` | `true` | no |
| subnets | List of subnet IDs to use. | `list(string)` | `[]` | no |
| timeout\_action | The action to take when the timeout is reached. Valid values: ForceApplyCapacityChange, RollbackCapacityChange. | `string` | `"RollbackCapacityChange"` | no |
| username | Master DB username. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
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
