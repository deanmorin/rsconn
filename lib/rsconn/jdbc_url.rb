module Rsconn
  class JdbcUrl
    attr_reader :url, :host, :port, :database

    def initialize(url)
      @url = url
      @host = @url.split('//').last.split(':').first
      @port = @url.split(':').last.split('/').first.to_i
      @database = @url.split('/').last.split('?').first

      db_type = @url.split(':')[1]

      unless %w(redshift postgresql).include?(db_type)
        fail ArgumentError, 'Only works with a "redshift" or "postgresql" JDBC URL'
      end
    end
  end
end
