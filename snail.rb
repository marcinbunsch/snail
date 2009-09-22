#!/usr/bin/env ruby

require 'rubygems'
# make sure we're using the right version of gems
gem 'sinatra', :version => '0.9.4'
gem 'right_aws', :version =>'1.10.0'
require 'sinatra'
require 'right_aws'
require 'yaml'
require 'ruby-debug'

# load all files in lib
Dir["lib/*.rb"].each { |x| load x }
# load actions
Dir["lib/actions/*.rb"].each { |x| load x }

# set s3_config
config_file = YAML.load_file("config/snail.yml")
set :config, config_file
set :projects, config_file.keys

before do
  @projects = options.projects
  first = request.path.split('/')[1]
  if config = options.config[first]
    @project = first
    @ec2 = RightAws::Ec2.new(config['aws_key'], config['aws_secret'])
    @s3 = RightAws::S3.new(config['aws_key'], config['aws_secret'])
  else
    redirect '/projects' if first != 'projects' and !File.exists?("public#{request.path}")
  end
end

helpers do
  include Helpers
end