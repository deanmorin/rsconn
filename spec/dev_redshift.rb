require 'rsconn'


module Rsconn
  class DevRedshift < Redshift

    def initialize(options={})
      super(
        ENV['RSCONN_JDBC_URL'],
        ENV['RSCONN_USER'],
        ENV['RSCONN_PASSWORD'],
        options
      )
    end
  end
end
