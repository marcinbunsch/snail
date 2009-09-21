# S3

get '/:project/buckets' do
  @buckets = @s3.buckets.map{|b| b.name}
  erb :buckets
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