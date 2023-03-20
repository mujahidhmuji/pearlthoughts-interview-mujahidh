# pearlthoughts-interview-mujahidh
pearlthoughts-interview-mujahidh
Requirements
Name	Version
terraform	>= 0.12
Providers
Name	Version
aws	n/a
Modules
No modules.

Resources
Name	Type
aws_s3_bucket.terraform_state	resource
Inputs
Name	Description	Type	Default	Required
aws_region	AWS region to provision	string	"us-west-2"	no
env_name	Name of environment	string	"Development"	no
Outputs
Name	Description
tf-state-bucket-name	n/a
