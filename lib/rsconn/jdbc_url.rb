module Rsconn
  class JdbcUrl
    attr_reader :url, :host, :port, :database

    def initialize(url)
      @url = url
      @host = @url.split('//').last.split(':').first
      @port = @url.split(':').last.split('/').first.to_i
      @database = @url.split('/').last

      db_type = @url.split(':')[1]

      if db_type != 'postgresql'
        fail ArgumentError, 'Only works with a "postgresql" JDBC URL'
      end
    end
  end
end
