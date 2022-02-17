If destroy operation will end up with error as below you will need to manually delete VPC resource from AWS console.

```
Error: error deleting EC2 VPC (vpc-xxxxxxxxx): DependencyViolation: The vpc 'vpc-xxxxxxxx' has dependencies and cannot be deleted.
       status code: 400, request id: dcebc7a2-6b40-475a-8cf9-bd58ef165967
```
Also you can use script "find_dependencies.sh" to find all resources associated with the VPC. Replace VPC ID before executing.