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
  new_memo = { 'id' => params['id'], 'title' => params['title'], 'content' => params['content'] }
  new_memos = push_memo(find_memos, new_memo)
  save_memos(new_memos)
  redirect to('/memos'), 303
end

patch '/memos/:id' do
  halt 400 if find_memo(params['id']).nil?

  new_memo = { 'id' => params['id'], 'title' => params['title'], 'content' => params['content'] }
  new_memos = update_memo(find_memos, new_memo)
  save_memos(new_memos)
  redirect to("/memos/#{params['id']}"), 303
end

delete '/memos/:id' do
  halt 400 if find_memo(params['id']).nil?

  new_memos = delete_memo(find_memos, params['id'])
  save_memos(new_memos)
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

def push_memo(memos, new_memo)
  memos << new_memo
end

def update_memo(memos, new_memo)
  memos.map do |memo|
    if memo['id'] == new_memo['id']
      {
        **memo,
        'title' => new_memo['title'],
        'content' => new_memo['content']
      }
    else
      memo
    end
  end
end

def delete_memo(memos, id)
  memos.filter { |memo| memo['id'] != id }
end

def save_memos(memos)
  File.write(DATA_FILE, JSON.generate(memos))
end
