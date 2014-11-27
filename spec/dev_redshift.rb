require 'rsconn'


module Rsconn
  class DevRedshift < Redshift

    def initialize(options={})
      unless ENV['RSCONN_JDBC_URL'] && ENV['RSCONN_USER'] && ENV['RSCONN_PASSWORD']
        fail 'The environment variables RSCONN_JDBC_URL, RSCONN_USER, and ' +
             'RSCONN_PASSWORD must be set to run the tests'
      end

      url = JdbcUrl.new(ENV['RSCONN_JDBC_URL'])

      super(
        url.host,
        url.port,
        url.database,
        ENV['RSCONN_USER'],
        ENV['RSCONN_PASSWORD'],
        options
      )
    end
  end
end
