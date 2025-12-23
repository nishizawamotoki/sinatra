require 'sinatra'
require 'json'

configure do
  set :method_override, true
  DATA_FILE = 'memos.json'
  File.write(DATA_FILE, '[]') unless File.exist?(DATA_FILE)
end

get '/memos' do
  @memos = JSON.load_file(DATA_FILE)
  
  erb :index
end

get '/memos/new' do
  memos = JSON.load_file(DATA_FILE)
  @new_id = memos.empty? ? 1 : memos.last['id'].to_i + 1

  erb :new
end

get '/memos/:id' do
  memo = find_memo(params['id'])
  if memo
    @memo = memo
  else
    halt 404
  end

  erb :show
end

get '/memos/:id/edit' do
  memo = find_memo(params['id'])
  if memo 
    @memo = memo
  else
    halt 404
  end

  erb :edit
end

post '/memos' do
  request.body.rewind
  old_memos = JSON.load_file(DATA_FILE)
  new_memos = [*old_memos, Hash[URI.decode_www_form(request.body.read)]]
  File.write(DATA_FILE, JSON.generate(new_memos))

  redirect to('/memos'), 303
end

patch '/memos/:id' do
  halt 400 if find_memo(params['id']).nil?

  request.body.rewind
  new_memo = Hash[URI.decode_www_form(request.body.read)]
  old_memos = JSON.load_file(DATA_FILE)
  new_memos = old_memos.map do |memo|
    if memo['id'] == params['id'] 
      {
        **memo,
        'title' => new_memo['title'],
        'content' => new_memo['content']
      }
    else
      memo
    end
  end
  File.write(DATA_FILE, JSON.generate(new_memos))

  redirect to("/memos/#{params['id']}"), 303
end

delete '/memos/:id' do
  halt 400 if find_memo(params['id']).nil?

  old_memos = JSON.load_file(DATA_FILE)
  new_memos = old_memos.filter { |memo| memo['id'] != params['id']}
  File.write(DATA_FILE, JSON.generate(new_memos))

  redirect to('/memos'), 303
end

not_found do
  '404 not found.'
end

def find_memo(id)
  memos = JSON.load_file(DATA_FILE)
  memos.find { |memo| memo['id'] == id }
end
