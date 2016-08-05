require 'bundler'
Bundler.require
require 'uri'

HOST = ENV['HOST']
raise "HOST is not set" unless HOST
USER = ENV['USER']
raise "USER is not set" unless USER
AUTHORIZED_KEYS_PATH = File.join(File.expand_path("~#{USER}"), ".ssh/authorized_keys")

module WildberryJam
  class Connection < ActiveRecord::Base
    before_create do
      k = SSHKey.generate
      self.ssh_private_key = k.private_key
      self.ssh_public_key = k.ssh_public_key
    end

    after_create do
      File.open(AUTHORIZED_KEYS_PATH, "a") do |f|
        f.write(self.ssh_public_key + "\n")
      end
    end

    def ssh_command
      "ssh -v -N -R #{self.tunnel_port}:localhost:1880 #{USER}@#{HOST}"
    end

    def nodered_url
      URI.join(URI::HTTP.build(:host => HOST, :port => self.downstream_port), "/red/#{self.tunnel_port}")
    end

    def tunnel_port
      self.id + 8000
    end

    def downstream_port
      9000
    end

    #def run_reverse_proxy
    #  pid = fork do
    #    
    #  end
    #  self.proxy_process_pid = pid
    #  self.save
    #end
  end

  class Application < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    configure do
      mime_type :plaintext, 'text/plain'
      register Sinatra::ActiveRecordExtension
      set :database, {adapter: "sqlite3", database: "db/db.sqlite"}
    end

    # routing
    get '/' do
      @connections = Connection.all
      haml :index, :layout => :layout
    end

    get '/connections/:id/private_key' do
      content_type :plaintext
      Connection.find(params[:id]).ssh_private_key
    end
  end
end

