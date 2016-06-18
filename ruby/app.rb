require 'sinatra'

require 'pg'
require 'json'
require 'uri'

set :bind, '0.0.0.0'
set :port, ENV['PORT']


get '/products' do
  content_type :json
  
  value = ""
  result = []
  begin
    uri = URI.parse(ENV['POSTGRES_URL'])
    client = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1 .. -1], uri.user, uri.password)
    res = client.query("SELECT * from product ORDER BY id ASC");
    res.each_row do |row|
      item = {}
      item['id'] = row[0].to_i
      item['name'] = row[1]
      item['quantity'] = row[2].to_i
      result << item
    end
    value = result
  rescue PG::ConnectionBad => e
    status 500
    value = {
      :error => e
    }
  ensure
    client.close() if client
  end
  
  value.to_json
end


if ENV['FOREMAN_WORKER_NAME'] == "web.1" then  
    sql = <<SQL
CREATE TABLE "product"
(
    id SERIAL NOT NULL,
    name character varying(20) NOT NULL,
    quantity int NOT NULL,
    CONSTRAINT product_pkey PRIMARY KEY (id)
);
SQL
  
  uri = URI.parse(ENV['POSTGRES_URL'])
  client = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1 .. -1], uri.user, uri.password)
  client.query(sql);
end

Thread.new do
  sleep 1
  print 'READY'
  STDOUT.flush
end