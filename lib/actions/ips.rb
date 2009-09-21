# Elastic IP addresses

get '/:project/addresses' do
  @addresses = @ec2.describe_addresses
  @instances = @ec2.describe_instances.reverse
  erb :addresses
end

get '/:project/addresses/allocate' do
  @ec2.allocate_address
  redirect '/addresses'
end

get '/:project/address/*/release' do
  ip_address = request.path_info.split('/')[2]
  @ec2.release_address(ip_address)
  redirect '/addresses'
end

post '/:project/address/*/associate' do
  ip_address = request.path_info.split('/')[2]
  @ec2.associate_address(params[:instance_id], ip_address)
  redirect '/addresses'
end

get '/:project/address/*/disassociate' do
  ip_address = request.path_info.split('/')[2]
  @ec2.disassociate_address(ip_address)
  redirect '/addresses'
end