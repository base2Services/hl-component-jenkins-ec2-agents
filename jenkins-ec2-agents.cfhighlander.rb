CfhighlanderTemplate do
  Name 'jenkins-ec2-agents'
  Description "jenkins-ec2-agents - #{component_version}"
  
  DependsOn 'lib-iam@0.2.0'
  
  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    ComponentParam 'S3Bucket'
    ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
    ComponentParam 'JenkinsMasterSecurityGroup', type: 'AWS::EC2::SecurityGroup::Id'
    ComponentParam 'Subnets', type: 'CommaDelimitedList'
  end

  LambdaFunctions 'ami_finder_custom_resources'

end
