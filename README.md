
**How to apply**
```
terraform init

terraform plan --var-file=terraform-demo.tfvars

terraform apply --var-file=terraform-demo.tfvars
```

**How to destroy**
```
terraform destroy --var-file=terraform-demo.tfvars
```

**If destroy operation will end up with error as below you need manually delete VPC resource from AWS console.**

<font color="red">
Error: error deleting EC2 VPC (vpc-xxxxxxxxx): DependencyViolation: The vpc 'vpc-xxxxxxxx' has dependencies and cannot be deleted.
       status code: 400, request id: dcebc7a2-6b40-475a-8cf9-bd58ef165967
</font>

https://aws.amazon.com/ru/premiumsupport/knowledge-center/troubleshoot-dependency-error-delete-vpc/

You can put the below lines in a bash script and get all the associations with the problem VPC
```
#!/bin/bash
vpc="vpc-xxxxxxx" 
aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep InternetGatewayId
aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$vpc | grep SubnetId
aws ec2 describe-route-tables --filters 'Name=vpc-id,Values='$vpc | grep RouteTableId
aws ec2 describe-network-acls --filters 'Name=vpc-id,Values='$vpc | grep NetworkAclId
aws ec2 describe-vpc-peering-connections --filters 'Name=requester-vpc-info.vpc-id,Values='$vpc | grep VpcPeeringConnectionId
aws ec2 describe-vpc-endpoints --filters 'Name=vpc-id,Values='$vpc | grep VpcEndpointId
aws ec2 describe-nat-gateways --filter 'Name=vpc-id,Values='$vpc | grep NatGatewayId
aws ec2 describe-security-groups --filters 'Name=vpc-id,Values='$vpc | grep GroupId
aws ec2 describe-instances --filters 'Name=vpc-id,Values='$vpc | grep InstanceId
aws ec2 describe-vpn-connections --filters 'Name=vpc-id,Values='$vpc | grep VpnConnectionId
aws ec2 describe-vpn-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep VpnGatewayId
aws ec2 describe-network-interfaces --filters 'Name=vpc-id,Values='$vpc | grep NetworkInterfaceId
```