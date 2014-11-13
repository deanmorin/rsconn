require 'rspec/its'
require 'rsconn/jdbc_url'


module Rsconn
  describe JdbcUrl do
    HOST = 'host.redshift.amazonaws.com'
    PORT = 5439
    DATABASE = 'dbname'
    JDBC_URL = "jdbc:postgresql://#{HOST}:#{PORT}/#{DATABASE}"
    MYSQL_URL = "jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE}"

    describe '#new' do

      context 'when a good url is given' do
        subject { JdbcUrl.new(JDBC_URL) }
        its(:url) { should eq(JDBC_URL) }
        its(:host) { should eq(HOST) }
        its(:port) { should eq(PORT) }
        its(:database) { should eq(DATABASE) }
      end

      context 'when a mysql url is given' do
        subject { JdbcUrl.new(MYSQL_URL) }
        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end
  end
end
