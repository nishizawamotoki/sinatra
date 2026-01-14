# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require 'json'

DATA_FILE = 'memos.json'

configure do
  set :method_override, true
  File.write(DATA_FILE, '[]') unless File.exist?(DATA_FILE)
end

helpers do
  def h(text)
    ERB::Util.h(text)
  end
end

get '/memos' do
  @memos = find_memos
  erb :index
end

get '/memos/new' do
  memos = find_memos
  @new_id = memos.empty? ? 1 : memos.last['id'].to_i + 1
  erb :new
end

get '/memos/:id' do
  @memo = find_memo(params['id'])
  halt 404 if @memo.nil?
  erb :show
end

get '/memos/:id/edit' do
  @memo = find_memo(params['id'])
  halt 404 if @memo.nil?
  erb :edit
end

post '/memos' do
  create_memo(params['id'], params['title'], params['content'])
  redirect to('/memos'), 303
end

patch '/memos/:id' do
  halt 400 if find_memo(params['id']).nil?

  update_memo(params['id'], params['title'], params['content'])
  redirect to("/memos/#{params['id']}"), 303
end

delete '/memos/:id' do
  halt 400 if find_memo(params['id']).nil?

  delete_memo(params['id'])
  redirect to('/memos'), 303
end

not_found do
  '404 not found.'
end

def find_memo(id)
  memos = find_memos
  memos.find { |memo| memo['id'] == id }
end

def find_memos
  JSON.load_file(DATA_FILE)
end

def create_memo(id, title, content)
  memos = find_memos
  memos << { 'id': id, 'title': title, 'content': content }
  File.write(DATA_FILE, JSON.generate(memos))
end

def update_memo(id, title, content)
  old_memos = find_memos
  new_memos = old_memos.map do |memo|
    if memo['id'] == id
      {
        **memo,
        'title' => title,
        'content' => content
      }
    else
      memo
    end
  end
  File.write(DATA_FILE, JSON.generate(new_memos))
end

def delete_memo(id)
  old_memos = find_memos
  new_memos = old_memos.filter { |memo| memo['id'] != id }
  File.write(DATA_FILE, JSON.generate(new_memos))
end
