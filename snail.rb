#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'right_aws'
require 'yaml'

Dir["lib/*.rb"].each { |x| load x }

configure do
  begin
    config = YAML.load_file("snail.yml")
  rescue
  end
  if config
    AWS_KEY = config['aws_key']
    AWS_SECRET = config['aws_secret']
    @@ec2 = RightAws::Ec2.new(AWS_KEY, AWS_SECRET)
    @@s3 = RightAws::S3.new(AWS_KEY, AWS_SECRET)
  end
end

before do
  @ec2 = @@ec2
  @s3 = @@s3
end

helpers do
  include Helpers
end

get '/' do
  redirect '/instances'
end

# Instances

get '/instances' do
  @instances = @ec2.describe_instances.reverse
  erb :instances
end

get '/instance/:instance_id/terminate' do
  @output = @ec2.terminate_instances(params[:instance_id])
  redirect '/instances'
end

get '/instance/:instance_id/output' do
  @output = @ec2.get_console_output(params[:instance_id])
  erb :output
end

get '/instance/:instance_id/reboot' do
  @ec2.reboot_instances([params[:instance_id]])
  redirect '/instances'
end

# Images

get '/images' do
  @@images ||= @ec2.describe_images.find_all{|x| x[:aws_image_type] == 'machine'}
  @i386 = @@images.find_all{|x| x[:aws_architecture] == 'i386'}.sort {|x,y| x[:aws_location] <=> y[:aws_location] }
  @x86_64 = @@images.find_all{|x| x[:aws_architecture] == 'x86_64'}.sort {|x,y| x[:aws_location] <=> y[:aws_location] }
  erb :images
end

get '/images/:image_id/launch' do
  @ec2.launch_instances(params[:image_id], :group_ids => 'default',
                            :user_data => "Woohoo!!!",
                            :addressing_type => "public",
                            :key_name => "default",
                            :availability_zone => "us-east-1c")
  redirect '/instances'
end

get '/images/search*' do
  params[:query] ||= request.path_info.split('/')[3]
  redirect '/images' if params[:query].empty?
  @i386 = @@images.find_all{|x| x[:aws_architecture] == 'i386' and x.inspect =~ /#{params[:query]}/i}.sort {|x,y| x[:aws_location] <=> y[:aws_location] }
  @x86_64 = @@images.find_all{|x| x[:aws_architecture] == 'x86_64' and x.inspect =~ /#{params[:query]}/i}.sort {|x,y| x[:aws_location] <=> y[:aws_location] }
  erb :images
end

# Elastic IP addresses

get '/addresses' do
  @addresses = @ec2.describe_addresses
  erb :addresses
end

get '/addresses/allocate' do
  @ec2.allocate_address
  redirect '/addresses'
end

get '/address/*/release' do
  ip_address = request.path_info.split('/')[2]
  @ec2.release_address(ip_address)
  redirect '/addresses'
end

get '/address/*/associate/:instance_id' do
  ip_address = request.path_info.split('/')[2]
  @ec2.associate_address(params[:instance_id], ip_address)
  redirect '/addresses'
end

get '/address/*/disassociate' do
  ip_address = request.path_info.split('/')[2]
  @ec2.disassociate_address(ip_address)
  redirect '/addresses'
end

# Security Groups

get '/groups' do
  @groups = @ec2.describe_security_groups
  erb :groups
end

get '/group/:group_name/delete' do
  @ec2.delete_security_group(params[:group_name])
  redirect '/groups'
end

get '/group/:group_name/revoke' do
  if params[:group]
    @ec2.revoke_security_group_named_ingress(params[:group_name], params[:owner], params[:group])
  else
    @ec2.revoke_security_group_IP_ingress(params[:group_name], params[:from], params[:to], params[:protocol], params[:ip])
  end
  redirect '/groups'
end

post '/group/:group_name/authorize' do
  @ec2.authorize_security_group_IP_ingress(params[:group_name], params[:from], params[:to], params[:protocol], params[:ip])
  redirect '/groups'
end

post '/group' do
  @ec2.create_security_group(params[:name], params[:description])
  redirect '/groups'
end

# SSH Key Pairs

get '/keys' do
  @keys = @ec2.describe_key_pairs
  erb :keys
end

# S3

get '/buckets' do
  @buckets = @s3.buckets.map{|b| b.name}
  erb :buckets
end

get '/bucket/:name/keys' do
  @output = @s3.bucket(params[:name]).keys.map{|k| k.name}
  erb :dump
end
