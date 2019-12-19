CfhighlanderTemplate do
  Name 'jenkins-ec2-agents'
  Description "jenkins-ec2-agents - #{component_version}"
  
  DependsOn 'lib-iam@0.1.0'
  
  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    ComponentParam 'S3Bucket'
    ComponentParam 'VPCId'
    ComponentParam 'JenkinsMasterSecurityGroup'
  end


end
