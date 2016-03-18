require 'rest_client'
require 'open-uri'
require 'uri'
require 'cgi'
require 'json'
require 'pry'
module Aem::Deploy

  class Session
    attr_reader :host, :user, :pass, :retry, :upload_path

    # Initialize the object
    # @param [Hash] including :host, :user and :pass REQUIRED, optional :retry [Integer] which will retry failures x times.
    # @raise [Error] if :host, :user and :pass are not passed on initialize
    def initialize(params)
      if [:host, :user, :pass].all? {|k| params.key?(k)}
        @host = params.fetch(:host)
        @user = params.fetch(:user)
        @pass = CGI.escape(params.fetch(:pass))
        @retry = params.fetch(:retry).to_i unless params[:retry].nil?
      else
        raise 'Hostname, User and Password are required'
      end
    end

    # See Upload and Install methods for individual descriptions
    # @param [String] path to the package for upload and installation.
    # @return [Hash] installation message from crx
    def easy_install(package_path)
      upload_package(package_path)
      install_package
    end

    # Uploads Package to CRX
    # @param [String] path to the package for upload and installation.
    # @return [Hash] installation message from crx.
    # @raise [Error] if server returns anything but success.
    def upload_package(package_path)
      upload = RestClient.post("http://#{@user}:#{@pass}@#{@host}/crx/packmgr/service/.json", :cmd => 'upload', :package => File.new(package_path, 'rb'), :force => true, :timeout => 300)
      parse_response(upload)
      @upload_path = URI.encode(JSON.parse(upload)["path"])
    rescue RestClient::RequestTimeout => error
      {error: error.to_s}.to_json
      if @retry
        puts 'retrying installation as there was a problem'
        retry unless (@retry -= 1).zero?
      end
    end

    # Installs Package to CRX
    # @param [Hash] Optionally install packages already on CRX uses :path key in options hash, if you know the path to the package on crx.
    # @return [Hash] installation message from crx.
    # @raise [Error] if server returns anything but success.
    def install_package(options = {})
      if options[:path]
        @upload_path = options[:path]
      end
      install = RestClient.post("http://#{user}:#{pass}@#{host}/crx/packmgr/service/.json#{@upload_path}", :cmd => 'install', :timeout => 300)
      parse_response(install)
    rescue RestClient::RequestTimeout => error
      {error: error.to_s}.to_json
      if @retry
        puts 'retrying installation as there was a problem'
        retry unless (@retry -= 1).zero?
      end
    end

    # Recompiles JSPs
    # @return [String] Recompile complete
    # @raise [Error] if server returns anything but success.
    def recompile_jsps
      begin
        RestClient.post "http://#{@user}:#{@pass}@#{@host}/system/console/slingjsp", :cmd => 'recompile', :timeout => 120
      rescue RestClient::Found => error
        return {msg: 'JSPs recompiled'}.to_json
      rescue RestClient::RequestTimeout => error
        {error: error.to_s}.to_json
        if @retry
          puts 'retrying installation as there was a problem'
          retry unless (@retry -= 1).zero?
        end
      end
    end

    # Parses message output from CRX
    # @return [String] Recompile complete
    # @raise [Error] if server returns anything but success.
    def parse_response(message)
      if JSON.parse(message)['success'] == true
        return "  #{message}"
      elsif message.include? ("302 Found")
        return '  JSPs Recompiled'
      else
        raise "  #{JSON.parse(message)}"
      end
    end
  end
end
