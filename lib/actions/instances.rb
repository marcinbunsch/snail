# Instances

get '/:project/instances' do
  @instances = @ec2.describe_instances.reverse
  erb :instances
end

get '/:project/instance/:instance_id/terminate' do
  @output = @ec2.terminate_instances(params[:instance_id])
  redirect '/instances'
end

get '/:project/instance/:instance_id/output' do
  @output = @ec2.get_console_output(params[:instance_id])
  erb :output
end

get '/:project/instance/:instance_id/reboot' do
  @ec2.reboot_instances([params[:instance_id]])
  redirect '/instances'
end
