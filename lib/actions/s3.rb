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
  @keys = @bucket.keys('max-keys' => 100).collect { |key| 
    { :link => "http://#{params[:bucket_name]}.s3.amazonaws.com/#{key}", 
      :name => key.name } 
  }
  erb :s3_keys
end

post '/:project/bucket/:bucket_name/upload' do
  if params[:bucket] and params[:bucket][:upload]
    filename = params[:bucket][:upload][:filename]
    file_data = params[:bucket][:upload][:tempfile].read
    @s3.bucket(params[:bucket_name]).put(filename, file_data)
  end
  redirect "/#{@project}/bucket/#{params[:bucket_name]}/keys"
end


get '/:project/bucket/:bucket_name/key/:key_name/delete' do
  if params[:bucket_name] and params[:key_name]
    bucket = @s3.bucket(params[:bucket_name] )
    RightAws::S3::Key.new(bucket, params[:key_name]).delete
  end
  redirect "/#{@project}/bucket/#{params[:bucket_name]}/keys"
end