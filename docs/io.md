## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allocated\_storage | The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster) | `number` | `null` | no |
| allow\_major\_version\_upgrade | Enable to allow major engine version upgrades when changing engine versions. Defaults to `false` | `bool` | `false` | no |
| allowed\_ip | List of allowed ip. | `list(any)` | `[]` | no |
| allowed\_ports | List of allowed ingress ports | `list(any)` | `[]` | no |
| apply\_immediately | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false` | `bool` | `null` | no |
| auth | n/a | `any` | `{}` | no |
| auto\_minor\_version\_upgrade | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `true` | `bool` | `null` | no |
| autoscaling\_enabled | Determines whether autoscaling of the cluster read replicas is enabled | `bool` | `false` | no |
| autoscaling\_max\_capacity | Maximum number of read replicas permitted when autoscaling is enabled | `number` | `2` | no |
| autoscaling\_min\_capacity | Minimum number of read replicas permitted when autoscaling is enabled | `number` | `0` | no |
| autoscaling\_policy\_name | Autoscaling policy name | `string` | `"target-metric"` | no |
| autoscaling\_scale\_in\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale in | `number` | `300` | no |
| autoscaling\_scale\_out\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale out | `number` | `300` | no |
| autoscaling\_target\_connections | Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max\_connections | `number` | `700` | no |
| autoscaling\_target\_cpu | CPU threshold which will initiate autoscaling | `number` | `70` | no |
| availability\_zones | List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply | `list(string)` | `null` | no |
| backtrack\_window | The target backtrack window, in seconds. Only available for `aurora` engine currently. To disable backtracking, set this value to 0. Must be between 0 and 259200 (72 hours) | `number` | `null` | no |
| backup\_retention\_period | The days to retain backups for. Default `7` | `number` | `7` | no |
| ca\_cert\_identifier | The identifier of the CA certificate for the DB instance | `string` | `null` | no |
| cidr\_blocks | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| cluster\_members | List of RDS Instances that are a part of this cluster | `list(string)` | `null` | no |
| cluster\_tags | A map of tags to add to only the cluster. Used for AWS Instance Scheduler tagging | `map(string)` | `{}` | no |
| cluster\_timeouts | Create, update, and delete timeout configurations for the cluster | `map(string)` | `{}` | no |
| connection\_borrow\_timeout | (Optional) The number of seconds for a proxy to wait for a connection to become available in the connection pool. Only applies when the proxy has opened its maximum number of connections and all connections are busy with client sessions. | `number` | `null` | no |
| copy\_tags\_to\_snapshot | Copy all Cluster `tags` to snapshots | `bool` | `null` | no |
| create | Whether cluster should be created (affects nearly all resources) | `bool` | `true` | no |
| create\_db\_cluster\_parameter\_group | Determines whether a cluster parameter should be created or use existing | `bool` | `false` | no |
| create\_db\_parameter\_group | Determines whether a DB parameter should be created or use existing | `bool` | `false` | no |
| create\_db\_proxy | (Optional) Set this to true to create RDS Proxy. | `bool` | `false` | no |
| create\_monitoring\_role | Determines whether to create the IAM role for RDS enhanced monitoring | `bool` | `true` | no |
| database\_name | Name for an automatically created database on cluster creation | `string` | `""` | no |
| db\_cluster\_db\_instance\_parameter\_group\_name | Instance parameter group to associate with all instances of the DB cluster. The `db_cluster_db_instance_parameter_group_name` is only valid in combination with `allow_major_version_upgrade` | `string` | `null` | no |
| db\_cluster\_instance\_class | The compute and memory capacity of each DB instance in the Multi-AZ DB cluster, for example db.m6g.xlarge. Not all DB instance classes are available in all AWS Regions, or for all database engines | `string` | `null` | no |
| db\_cluster\_parameter\_group\_description | The description of the DB cluster parameter group. Defaults to "Managed by Terraform" | `string` | `null` | no |
| db\_cluster\_parameter\_group\_family | The family of the DB cluster parameter group | `string` | `""` | no |
| db\_cluster\_parameter\_group\_name | The name of the DB cluster parameter group | `string` | `null` | no |
| db\_cluster\_parameter\_group\_parameters | A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other | `list(map(string))` | `[]` | no |
| db\_parameter\_group\_description | The description of the DB parameter group. Defaults to "Managed by Terraform" | `string` | `null` | no |
| db\_parameter\_group\_family | The family of the DB parameter group | `string` | `""` | no |
| db\_parameter\_group\_name | The name of the DB parameter group | `string` | `null` | no |
| db\_parameter\_group\_parameters | A list of DB parameters to apply. Note that parameters may differ from a family to an other | `list(map(string))` | `[]` | no |
| debug\_logging | (Optional) Whether the proxy includes detailed information about SQL statements in its logs. This information helps you to debug issues involving SQL behavior or the performance and scalability of the proxy connections. The debug information includes the text of SQL statements that you submit through the proxy. Thus, only enable this setting when needed for debugging, and only when you have security measures in place to safeguard any sensitive information that appears in the logs. | `bool` | `false` | no |
| deletion\_protection | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false` | `bool` | `null` | no |
| egress\_protocol | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `number` | `-1` | no |
| egress\_rule | Enable to create egress rule | `bool` | `true` | no |
| enable | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| enable\_default\_proxy\_iam\_role | (OPTIONAL) Set this to false to pass your own IAM Role for RDS Proxy. | `bool` | `true` | no |
| enable\_global\_write\_forwarding | Whether cluster should forward writes to an associated global cluster. Applied to secondary clusters to enable them to forward writes to an `aws_rds_global_cluster`'s primary cluster | `bool` | `null` | no |
| enable\_http\_endpoint | Enable HTTP endpoint (data API). Only valid when engine\_mode is set to `serverless` | `bool` | `null` | no |
| enable\_security\_group | Enable default Security Group with only Egress traffic allowed. | `bool` | `true` | no |
| enabled\_cloudwatch\_logs\_exports | Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql` | `list(string)` | `[]` | no |
| enabled\_subnet\_group | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| endpoints | Map of additional cluster endpoints and their attributes to be created | `any` | `{}` | no |
| engine | The name of the database engine to be used for this DB cluster. Defaults to `aurora`. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql` | `string` | `null` | no |
| engine\_family | (Required, Forces new resource) The kinds of databases that the proxy can connect to. This value determines which database network protocol the proxy recognizes when it interprets network traffic to and from the database. For Aurora MySQL, RDS for MariaDB, and RDS for MySQL databases, specify MYSQL. For Aurora PostgreSQL and RDS for PostgreSQL databases, specify POSTGRESQL. For RDS for Microsoft SQL Server, specify SQLSERVER. Valid values are MYSQL, POSTGRESQL, and SQLSERVER. | `string` | `"POSTGRESQL"` | no |
| engine\_mode | The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned` | `string` | `"provisioned"` | no |
| engine\_version | The database engine version. Updating this argument results in an outage | `string` | `null` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| final\_snapshot\_identifier | The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made | `string` | `null` | no |
| from\_port | (Required) Start port (or ICMP type number if protocol is icmp or icmpv6). | `number` | `0` | no |
| global\_cluster\_identifier | The global cluster identifier specified on `aws_rds_global_cluster` | `string` | `null` | no |
| iam\_database\_authentication\_enabled | Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled | `bool` | `null` | no |
| iam\_role\_description | Description of the monitoring role | `string` | `null` | no |
| iam\_role\_force\_detach\_policies | Whether to force detaching any policies the monitoring role has before destroying it | `bool` | `null` | no |
| iam\_role\_managed\_policy\_arns | Set of exclusive IAM managed policy ARNs to attach to the monitoring role | `list(string)` | `null` | no |
| iam\_role\_max\_session\_duration | Maximum session duration (in seconds) that you want to set for the monitoring role | `number` | `null` | no |
| iam\_role\_path | Path for the monitoring role | `string` | `null` | no |
| iam\_role\_permissions\_boundary | The ARN of the policy that is used to set the permissions boundary for the monitoring role | `string` | `null` | no |
| iam\_roles | Map of IAM roles and supported feature names to associate with the cluster | `map(map(string))` | `{}` | no |
| idle\_client\_timeout | (Optional) The number of seconds that a connection to the proxy can be inactive before the proxy disconnects it. You can set this value higher or lower than the connection timeout limit for the associated database. | `number` | `1800` | no |
| init\_query | (Optional) One or more SQL statements for the proxy to run when opening each new database connection. Typically used with SET statements to make sure that each connection has identical settings such as time zone and character set. This setting is empty by default. For multiple statements, use semicolons as the separator. You can also include multiple variables in a single SET statement, such as SET x=1, y=2. | `string` | `""` | no |
| instance\_class | Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling | `string` | `""` | no |
| instance\_timeouts | Create, update, and delete timeout configurations for the cluster instance(s) | `map(string)` | `{}` | no |
| instances | Map of cluster instances and any specific/overriding attributes to be created | `any` | `{}` | no |
| instances\_use\_identifier\_prefix | Determines whether cluster instance identifiers are used as prefixes | `bool` | `false` | no |
| iops | The amount of Provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the Multi-AZ DB cluster | `number` | `null` | no |
| ipv6\_cidr\_blocks | Enable to create egress rule | `list(string)` | <pre>[<br>  "::/0"<br>]</pre> | no |
| is\_primary\_cluster | Determines whether cluster is primary cluster with writer instance (set to `false` for global cluster and replica clusters) | `bool` | `true` | no |
| kms\_key\_id | The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true` | `string` | `null` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| manage\_master\_user\_password | Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if `master_password` is provided | `bool` | `true` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| master\_user\_secret\_kms\_key\_id | The Amazon Web Services KMS key identifier is the key ARN, key ID, alias ARN, or alias name for the KMS key | `string` | `null` | no |
| master\_username | Username for the master DB user. Required unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database | `string` | `null` | no |
| max\_connections\_percent | (Optional) The maximum size of the connection pool for each target in a target group. For Aurora MySQL, it is expressed as a percentage of the max\_connections setting for the RDS DB instance or Aurora DB cluster used by the target group. | `number` | `100` | no |
| max\_idle\_connections\_percent | (Optional) Controls how actively the proxy closes idle database connections in the connection pool. A high value enables the proxy to leave a high percentage of idle connections open. A low value causes the proxy to close idle client connections and return the underlying database connections to the connection pool. For Aurora MySQL, it is expressed as a percentage of the max\_connections setting for the RDS DB instance or Aurora DB cluster used by the target group. | `number` | `null` | no |
| monitoring\_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disable. Default is `0` | `number` | `0` | no |
| monitoring\_role\_arn | IAM role used by RDS to send enhanced monitoring metrics to CloudWatch | `string` | `""` | no |
| monitoring\_role\_name | Name of the IAM role which will be created when create\_monitoring\_role is enabled. | `string` | `"rds-monitoring-role"` | no |
| mysql\_iam\_role\_tags | Additional tags for the mysql iam role | `map(any)` | `{}` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | n/a | yes |
| network\_type | The type of network stack to use (IPV4 or DUAL) | `string` | `null` | no |
| performance\_insights\_enabled | Specifies whether Performance Insights is enabled or not | `bool` | `null` | no |
| performance\_insights\_kms\_key\_id | The ARN for the KMS key to encrypt Performance Insights data | `string` | `null` | no |
| performance\_insights\_retention\_period | Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years) | `number` | `null` | no |
| port | The port on which the DB accepts connections | `string` | `null` | no |
| predefined\_metric\_type | The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections` | `string` | `"RDSReaderAverageCPUUtilization"` | no |
| preferred\_backup\_window | The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC | `string` | `"02:00-03:00"` | no |
| preferred\_maintenance\_window | The weekly time range during which system maintenance can occur, in (UTC) | `string` | `"sun:05:00-sun:06:00"` | no |
| protocol | The protocol. If not icmp, tcp, udp, or all use the. | `string` | `"tcp"` | no |
| proxy\_endpoints | Map of DB proxy endpoints to create and their attributes (see `aws_db_proxy_endpoint`) | `any` | `{}` | no |
| proxy\_iam\_role\_description | Description of the monitoring role | `string` | `null` | no |
| proxy\_iam\_role\_path | Path for the monitoring role | `string` | `null` | no |
| proxy\_role\_arn | (OPTIONAL) ARN of RDS proxy IAM Role. Can only be set when `enable_default_proxy_iam_role` is set to `false`. | `string` | `""` | no |
| proxy\_sg\_ids | (Optional) One or more VPC security group IDs to associate with the new proxy. | `list(string)` | `[]` | no |
| proxy\_subnet\_ids | (Required) One or more VPC subnet IDs to associate with the new proxy. | `list(string)` | `[]` | no |
| publicly\_accessible | Determines whether instances are publicly accessible. Default `false` | `bool` | `false` | no |
| replication\_source\_identifier | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica | `string` | `null` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-aurora"` | no |
| require\_tls | (Optional) A Boolean parameter that specifies whether Transport Layer Security (TLS) encryption is required for connections to the proxy. By enabling this setting, you can enforce encrypted TLS connections to the proxy. | `bool` | `false` | no |
| restore\_to\_point\_in\_time | Map of nested attributes for cloning Aurora cluster | `map(string)` | `{}` | no |
| s3\_import | Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported) | `map(string)` | `{}` | no |
| scaling\_configuration | Map of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless` | `map(string)` | `{}` | no |
| serverlessv2\_scaling\_configuration | Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned` | `map(string)` | `{}` | no |
| session\_pinning\_filters | (Optional) Each item in the list represents a class of SQL operations that normally cause all later statements in a session using a proxy to be pinned to the same underlying database connection. Including an item in the list exempts that class of SQL operations from the pinning behavior. Currently, the only allowed value is EXCLUDE\_VARIABLE\_SETS. | `list(string)` | `[]` | no |
| sg\_description | The security group description. | `string` | `"Instance default security group (only egress access is allowed)."` | no |
| sg\_egress\_description | Description of the egress and ingress rule | `string` | `"Description of the rule."` | no |
| sg\_egress\_ipv6\_description | Description of the egress\_ipv6 rule | `string` | `"Description of the rule."` | no |
| sg\_ids | of the security group id. | `list(any)` | `[]` | no |
| sg\_ingress\_description | Description of the ingress rule | `string` | `"Description of the ingress rule use elasticache."` | no |
| skip\_final\_snapshot | Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created | `bool` | `false` | no |
| snapshot\_identifier | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot | `string` | `null` | no |
| source\_region | The source region for an encrypted replica DB cluster | `string` | `null` | no |
| storage\_encrypted | Specifies whether the DB cluster is encrypted. The default is `true` | `bool` | `true` | no |
| storage\_type | Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: `io1`, Default: `io1` | `string` | `null` | no |
| subnets | List of subnet IDs used by database subnet group created | `list(string)` | `[]` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| to\_port | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `number` | `65535` | no |
| vpc\_id | ID of the VPC where to create security group | `string` | `""` | no |
| vpc\_security\_group\_ids | List of VPC security groups to associate to the cluster in addition to the security group created | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| additional\_cluster\_endpoints | A map of additional cluster endpoints and their attributes |
| cluster\_arn | Amazon Resource Name (ARN) of cluster |
| cluster\_database\_name | Name for an automatically created database on cluster creation |
| cluster\_endpoint | Writer endpoint for the cluster |
| cluster\_engine\_version\_actual | The running version of the cluster database |
| cluster\_hosted\_zone\_id | The Route53 Hosted Zone ID of the endpoint |
| cluster\_id | The RDS Cluster Identifier |
| cluster\_instances | A map of cluster instances and their attributes |
| cluster\_master\_password | The database master password |
| cluster\_master\_user\_secret | The generated database master user secret when `manage_master_user_password` is set to `true` |
| cluster\_master\_username | The database master username |
| cluster\_members | List of RDS Instances that are a part of this cluster |
| cluster\_port | The database port |
| cluster\_reader\_endpoint | A read-only endpoint for the cluster, automatically load-balanced across replicas |
| cluster\_resource\_id | The RDS Cluster Resource ID |
| cluster\_role\_associations | A map of IAM roles associated with the cluster and their attributes |
| db\_cluster\_parameter\_group\_arn | The ARN of the DB cluster parameter group created |
| db\_cluster\_parameter\_group\_id | The ID of the DB cluster parameter group created |
| db\_parameter\_group\_arn | The ARN of the DB parameter group created |
| db\_parameter\_group\_id | The ID of the DB parameter group created |
| enhanced\_monitoring\_iam\_role\_arn | The Amazon Resource Name (ARN) specifying the enhanced monitoring role |
| enhanced\_monitoring\_iam\_role\_name | The name of the enhanced monitoring role |
| enhanced\_monitoring\_iam\_role\_unique\_id | Stable and unique string identifying the enhanced monitoring role |
| proxy\_arn | The Amazon Resource Name (ARN) for the proxy |
| proxy\_default\_target\_group\_arn | The Amazon Resource Name (ARN) for the default target group |
| proxy\_default\_target\_group\_id | The ID for the default target group |
| proxy\_default\_target\_group\_name | The name of the default target group |
| proxy\_endpoint | The endpoint that you can use to connect to the proxy |
| proxy\_iam\_policy\_name | The name of the policy attached to RDS Proxy IAM Role. |
| proxy\_iam\_role\_arn | Amazon Resource Name (ARN) specifying the RDS Proxy role. |
| proxy\_iam\_role\_name | Name of the RDS Proxy IAM Role. |
| proxy\_iam\_role\_unique\_id | Stable and unique string identifying the RDS Proxy role. |
| proxy\_id | The ID of the rds proxy |
| proxy\_name | Identifier representing the DB Instance or DB Cluster target |
| proxy\_target\_endpoint | Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type |
| proxy\_target\_id | Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/) |
| proxy\_target\_port | Port for the target RDS DB Instance or Aurora DB Cluster |
| proxy\_target\_target\_arn | Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API |
| proxy\_target\_tracked\_cluster\_id | DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS\_INSTANCE target that is part of a DB Cluster |
| proxy\_target\_type | Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER` |
| security\_group\_id | The security group ID of the cluster |
