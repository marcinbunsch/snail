# S3

get '/:project/buckets' do
  @buckets = @s3.buckets.map{|b| { :name => b.name, :location => (b.location != '' ? b.location : 'US') } }
  erb :buckets
end

post '/:project/buckets' do
  if params[:bucket] and params[:bucket][:name]
    headers = {}
    headers[:location] = :eu if params[:bucket][:location] == 'eu'
    @s3.interface.create_bucket(params[:bucket][:name], headers)
  end
  redirect "/#{@project}/buckets"
end

get '/:project/bucket/:bucket_name/delete' do
  @s3.interface.delete_bucket(params[:bucket_name])
  redirect "/#{@project}/buckets"
end

get '/:project/bucket/:bucket_name/keys' do
  @bucket = @s3.bucket(params[:bucket_name])
  @keys = @bucket.keys
  erb :s3_keys
end

get '/:project/bucket/*/key/*' do
  bucket_name = request.path_info.split('/')[2]
  key_name = request.path_info.split('/')[4]
  @bucket = @s3.bucket(bucket_name)
  send_data(@bucket.get(key_name))
end