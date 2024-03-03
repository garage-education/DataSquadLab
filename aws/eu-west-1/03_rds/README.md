<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.34.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datasquad_app_db_kms"></a> [datasquad\_app\_db\_kms](#module\_datasquad\_app\_db\_kms) | terraform-aws-modules/kms/aws | ~> 1.0 |
| <a name="module_datasquad_app_rds_security_group"></a> [datasquad\_app\_rds\_security\_group](#module\_datasquad\_app\_rds\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.0 |
| <a name="module_datasquad_be_app_rds_db"></a> [datasquad\_be\_app\_rds\_db](#module\_datasquad\_be\_app\_rds\_db) | terraform-aws-modules/rds/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_parameter_group.pg_db_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datasquad_be_app_rds_db_address"></a> [datasquad\_be\_app\_rds\_db\_address](#output\_datasquad\_be\_app\_rds\_db\_address) | The address of the RDS instance |
| <a name="output_datasquad_be_app_rds_db_arn"></a> [datasquad\_be\_app\_rds\_db\_arn](#output\_datasquad\_be\_app\_rds\_db\_arn) | The ARN of the RDS instance |
| <a name="output_datasquad_be_app_rds_db_availability_zone"></a> [datasquad\_be\_app\_rds\_db\_availability\_zone](#output\_datasquad\_be\_app\_rds\_db\_availability\_zone) | The availability zone of the RDS instance |
| <a name="output_datasquad_be_app_rds_db_cloudwatch_log_groups"></a> [datasquad\_be\_app\_rds\_db\_cloudwatch\_log\_groups](#output\_datasquad\_be\_app\_rds\_db\_cloudwatch\_log\_groups) | Map of CloudWatch log groups created and their attributes |
| <a name="output_datasquad_be_app_rds_db_endpoint"></a> [datasquad\_be\_app\_rds\_db\_endpoint](#output\_datasquad\_be\_app\_rds\_db\_endpoint) | The connection endpoint |
| <a name="output_datasquad_be_app_rds_db_engine"></a> [datasquad\_be\_app\_rds\_db\_engine](#output\_datasquad\_be\_app\_rds\_db\_engine) | The database engine |
| <a name="output_datasquad_be_app_rds_db_engine_version_actual"></a> [datasquad\_be\_app\_rds\_db\_engine\_version\_actual](#output\_datasquad\_be\_app\_rds\_db\_engine\_version\_actual) | The running version of the database |
| <a name="output_datasquad_be_app_rds_db_enhanced_monitoring_iam_role_arn"></a> [datasquad\_be\_app\_rds\_db\_enhanced\_monitoring\_iam\_role\_arn](#output\_datasquad\_be\_app\_rds\_db\_enhanced\_monitoring\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the monitoring role |
| <a name="output_datasquad_be_app_rds_db_hosted_zone_id"></a> [datasquad\_be\_app\_rds\_db\_hosted\_zone\_id](#output\_datasquad\_be\_app\_rds\_db\_hosted\_zone\_id) | The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record) |
| <a name="output_datasquad_be_app_rds_db_identifier"></a> [datasquad\_be\_app\_rds\_db\_identifier](#output\_datasquad\_be\_app\_rds\_db\_identifier) | The RDS instance identifier |
| <a name="output_datasquad_be_app_rds_db_key_arn"></a> [datasquad\_be\_app\_rds\_db\_key\_arn](#output\_datasquad\_be\_app\_rds\_db\_key\_arn) | DB encrypted KMS ID |
| <a name="output_datasquad_be_app_rds_db_master_user_secret_arn"></a> [datasquad\_be\_app\_rds\_db\_master\_user\_secret\_arn](#output\_datasquad\_be\_app\_rds\_db\_master\_user\_secret\_arn) | The ARN of the master user secret (Only available when manage\_master\_user\_password is set to true) |
| <a name="output_datasquad_be_app_rds_db_name"></a> [datasquad\_be\_app\_rds\_db\_name](#output\_datasquad\_be\_app\_rds\_db\_name) | The database name |
| <a name="output_datasquad_be_app_rds_db_parameter_group_arn"></a> [datasquad\_be\_app\_rds\_db\_parameter\_group\_arn](#output\_datasquad\_be\_app\_rds\_db\_parameter\_group\_arn) | The ARN of the db parameter group |
| <a name="output_datasquad_be_app_rds_db_parameter_group_id"></a> [datasquad\_be\_app\_rds\_db\_parameter\_group\_id](#output\_datasquad\_be\_app\_rds\_db\_parameter\_group\_id) | The db parameter group id |
| <a name="output_datasquad_be_app_rds_db_port"></a> [datasquad\_be\_app\_rds\_db\_port](#output\_datasquad\_be\_app\_rds\_db\_port) | The database port |
| <a name="output_datasquad_be_app_rds_db_resource_id"></a> [datasquad\_be\_app\_rds\_db\_resource\_id](#output\_datasquad\_be\_app\_rds\_db\_resource\_id) | The RDS Resource ID of this instance |
| <a name="output_datasquad_be_app_rds_db_status"></a> [datasquad\_be\_app\_rds\_db\_status](#output\_datasquad\_be\_app\_rds\_db\_status) | The RDS instance status |
| <a name="output_datasquad_be_app_rds_db_subnet_group_arn"></a> [datasquad\_be\_app\_rds\_db\_subnet\_group\_arn](#output\_datasquad\_be\_app\_rds\_db\_subnet\_group\_arn) | The ARN of the db subnet group |
| <a name="output_datasquad_be_app_rds_db_subnet_group_id"></a> [datasquad\_be\_app\_rds\_db\_subnet\_group\_id](#output\_datasquad\_be\_app\_rds\_db\_subnet\_group\_id) | The db subnet group name |
| <a name="output_datasquad_be_app_rds_db_username"></a> [datasquad\_be\_app\_rds\_db\_username](#output\_datasquad\_be\_app\_rds\_db\_username) | The master username for the database |
<!-- END_TF_DOCS -->