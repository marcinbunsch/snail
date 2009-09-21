# Security Groups

get '/:project/groups' do
  @groups = @ec2.describe_security_groups
  erb :groups
end

get '/:project/group/:group_name/delete' do
  @ec2.delete_security_group(params[:group_name])
  redirect '/groups'
end

get '/:project/group/:group_name/revoke' do
  if params[:group]
    @ec2.revoke_security_group_named_ingress(params[:group_name], params[:owner], params[:group])
  else
    @ec2.revoke_security_group_IP_ingress(params[:group_name], params[:from], params[:to], params[:protocol], params[:ip])
  end
  redirect '/groups'
end

post '/:project/group/:group_name/authorize' do
  @ec2.authorize_security_group_IP_ingress(params[:group_name], params[:from], params[:to], params[:protocol], params[:ip])
  redirect '/groups'
end

post '/:project/group' do
  @ec2.create_security_group(params[:name], params[:description])
  redirect '/groups'
end