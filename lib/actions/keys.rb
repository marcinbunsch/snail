# SSH Key Pairs

get '/:project/keys' do
  @keys = @ec2.describe_key_pairs
  erb :keys
end

get '/:project/key/:key_name/delete' do
  @ec2.delete_key_pair(params[:key_name])
  redirect '/keys'
end

post '/:project/key' do
  output = @ec2.create_key_pair(params[:key_name])
  "<pre>" + output[:aws_material] + "</pre>"
end