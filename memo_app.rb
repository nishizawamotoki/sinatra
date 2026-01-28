# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require 'json'
require 'pg'

DB_NAME = 'memo_app'

configure do
  set :method_override, true
  set :db_conn, PG.connect(dbname: DB_NAME)
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
  halt 400 if params['title'].to_s.empty? || params['content'].nil?

  create_memo(params['title'], params['content'])
  redirect to('/memos'), 303
end

patch '/memos/:id' do
  halt 400 if params['title'].to_s.empty? || params['content'].nil?
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
  '404 Not Found.'
end

error 400 do
  '400 Bad Request.'
end

def find_memo(id)
  settings.db_conn.exec_params('SELECT * FROM memos WHERE id = $1', [id]).first
end

def find_memos
  settings.db_conn.exec_params('SELECT * FROM memos ORDER BY id')
end

def create_memo(title, content)
  settings.db_conn.exec_params('INSERT INTO memos (title, content) VALUES ($1, $2)', [title, content])
end

def update_memo(id, title, content)
  settings.db_conn.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [title, content, id])
end

def delete_memo(id)
  settings.db_conn.exec_params('DELETE FROM memos WHERE id = $1', [id])
end
