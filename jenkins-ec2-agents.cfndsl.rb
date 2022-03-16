CloudFormation do
  
  agent_tags = []
  agent_tags << { Key: 'Name', Value: FnSub("${EnvironmentName}-#{external_parameters[:component_name]}") }
  agent_tags << { Key: 'EnvironmentName', Value: Ref(:EnvironmentName) }
  agent_tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }
  
  iam_policies = external_parameters.fetch(:iam_policies, {})
  
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
    GroupDescription FnSub("${EnvironmentName}-#{external_parameters[:component_name]}")
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

  EC2_SecurityGroupIngress(:SelfSSHIngressRule) {
    Description 'ssh access for packer instances'
    FromPort 22
    ToPort 22
    IpProtocol 'TCP'
    GroupId Ref(:SecurityGroup)
  }
  
  Resource(:LinuxAmiFinder) {
    Type 'Custom::LinuxAmiFinder'
    Property 'ServiceToken', FnGetAtt(:AmiFinderCR, :Arn)
    Property 'Name', linux_ami
  }

  SSM_Parameter(:LinuxAmiParameter) {
    Description "AMI Id for the Jenkins linux agent"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/linux/ami")
    Property('Tier','Standard')
    Type 'String'
    Value Ref(:LinuxAmiFinder)
    Property('Tags',{
      Name: "#{external_parameters[:component_name]}-linux-ami",
      EnvironmentName: Ref(:EnvironmentName)
    })
  }

  SSM_Parameter(:WindowsAmiParameter) {
    Description "AMI Id for the Jenkins linux agent"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/windows/ami")
    Property('Tier','Standard')
    Type 'String'
    Value 'ami-replaceme'
    Property('Tags',{
      Name: "#{external_parameters[:component_name]}-windows-ami",
      EnvironmentName: Ref(:EnvironmentName)
    })
  }
  
  SSM_Parameter(:SubnetsParameter) {
    Description "AMI Id for the Jenkins linux agent"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/subnets")
    Property('Tier','Standard')
    Type 'String'
    Value FnJoin(' ', Ref(:Subnets))
    Property('Tags',{
      Name: "#{external_parameters[:component_name]}-subnets",
      EnvironmentName: Ref(:EnvironmentName)
    })
  }
  
  SSM_Parameter(:SecurityGroupParameter) {
    Description "AMI Id for the Jenkins linux agent"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/securitygroup")
    Property('Tier','Standard')
    Type 'String'
    Value Ref(:SecurityGroup)
    Property('Tags',{
      Name: "#{external_parameters[:component_name]}-security-group",
      EnvironmentName: Ref(:EnvironmentName)
    })
  }
  
  SSM_Parameter(:InstanceProfileParameter) {
    Description "Instance Profile for the Jenkins linux agent"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/iam")
    Property('Tier','Standard')
    Type 'String'
    Value FnGetAtt(:InstanceProfile,:Arn)
    Property('Tags',{
      Name: "#{external_parameters[:component_name]}-instance-profile",
      EnvironmentName: Ref(:EnvironmentName)
    })
  }

  SSM_Parameter(:JenkinsEFSParameter) {
    Description "Jenkins EFS ID"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/efs")
    Property('Tier','Standard')
    Type 'String'
    Value Ref(:JenkinsFileSystem)
    Property('Tags',{
      Name: "#{external_parameters[:component_name]}-efs-id",
      EnvironmentName: Ref(:EnvironmentName)
    })
  }

  SSM_Parameter(:JenkinsAgentCacheAccessPointParameter) {
    Description "Jenkins EFS agent access point ID for the Jenkins linux agent to attach in userdata for caching builds"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/cache-ap")
    Property('Tier','Standard')
    Type 'String'
    Value Ref(:JenkinsAgentCacheAccessPoint)
    Property('Tags',{
      Name: "#{external_parameters[:component_name]}-efs-cache-access-point",
      EnvironmentName: Ref(:EnvironmentName)
    })
  }
  
end
