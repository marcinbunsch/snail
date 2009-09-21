get '/' do
  redirect '/projects'
end

get '/projects' do
  erb :projects
end
