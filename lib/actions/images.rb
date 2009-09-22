# Images

get '/:project/images' do
  @@images ||= @ec2.describe_images_by_owner('self')
  # @@images ||= @ec2.describe_images_by_executable_by('self')
  # @@images ||= @ec2.describe_images.find_all{|x| x[:aws_image_type] == 'machine'}
  @i386 = @@images.find_all{|x| x[:aws_architecture] == 'i386'}.sort {|x,y| x[:aws_location] <=> y[:aws_location] }
  @x86_64 = @@images.find_all{|x| x[:aws_architecture] == 'x86_64'}.sort {|x,y| x[:aws_location] <=> y[:aws_location] }
  erb :images
end

get '/:project/images/:image_id/launch' do
  @ec2.launch_instances(params[:image_id], :group_ids => 'default',
                            :user_data => "Woohoo!!!",
                            :addressing_type => "public",
                            :key_name => "default",
                            :availability_zone => "us-east-1c")
  redirect '/instances'
end

get '/:project/images/search*' do
  params[:query] ||= request.path_info.split('/')[3]
  redirect '/images' if params[:query].empty?
  @i386 = @@images.find_all{|x| x[:aws_architecture] == 'i386' and x.inspect =~ /#{params[:query]}/i}.sort {|x,y| x[:aws_location] <=> y[:aws_location] }
  @x86_64 = @@images.find_all{|x| x[:aws_architecture] == 'x86_64' and x.inspect =~ /#{params[:query]}/i}.sort {|x,y| x[:aws_location] <=> y[:aws_location] }
  erb :images
end