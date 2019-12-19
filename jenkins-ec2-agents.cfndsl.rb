CloudFormation do
  
  agent_tags = []
  agent_tags << { Key: 'Name', Value: FnSub("${EnvironmentName}-#{component_name}") }
  agent_tags << { Key: 'EnvironmentName', Value: Ref(:EnvironmentName) }
  agent_tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }
  
  IAM_Role(:Role) {
    Path '/'
    AssumeRolePolicyDocument service_assume_role_policy('ec2')
    Policies iam_role_policies(iam_policies)
    Tags agent_tags
  }
  
  InstanceProfile(:InstanceProfile) {
    Path '/'
    Roles [Ref(:Role)]
  }
  
  EC2_SecurityGroup(:SecurityGroup) {
    VpcId Ref(:VPCId)
    GroupDescription FnSub("${EnvironmentName}-#{component_name}")
    SecurityGroupIngress([
      {
        Description: 'ssh access from jenkins master',
        FromPort: 22,
        ToPort: 22,
        IpProtocol: 'TCP',
        SourceSecurityGroupId: Ref(:JenkinsMasterSecurityGroup)
      }
    ])
    SecurityGroupEgress([
      {
        CidrIp: '0.0.0.0/0',
        IpProtocol: '-1'
      }
    ])
    Tags agent_tags
  }
  
end
