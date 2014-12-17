require 'pg'
require 'rsconn/jdbc_url'
require 'rsconn/logger'
require 'rsconn/typecast_result'


module Rsconn
  class PG::Result
    def length
      ntuples
    end
  end


  class Postgres
    attr_reader :conn

    def initialize(host, port, database, user, password, options={})
      fail_if_invalid_connection_credentials(host, port, database, user, password)

      @host = host
      @port = port
      @database = database
      @user = user
      @password = password
      @abort_on_error = options.fetch(:abort_on_error, true)
      @max_retries = options.fetch(:max_retries, 3)
      @quiet = options.fetch(:quiet, false)
      @error_occurred = false
      @retry_count = 0

      secrets = options.fetch(:secrets, [])
      @logger = Logger.new(:secrets => secrets)

      init_connection
    end

    def execute(sql, options={})
      quiet = options.fetch(:quiet, @quiet)

      log "\n#{sql}\n" unless quiet
      result = with_error_handling { @conn.exec(sql) }
      return nil if @error_occurred

      cmd = result.cmd_status.split.first
      affected_rows = result.cmd_tuples

      if %w(INSERT UPDATE DELETE MOVE FETCH).include?(cmd)
        log "Affected #{affected_rows} row(s)." unless quiet
      end

      affected_rows
    end

    def query(sql, options={})
      quiet = options.fetch(:quiet, @quiet)

      log "\n#{sql}\n" unless quiet
      result = with_error_handling { @conn.exec(sql) }
      return nil if @error_occurred

      TypecastResult.new(result).result
    end

    def execute_script(filename, options={})
      File.open(filename) do |fh|
        sql = fh.read
        sql = remove_comments(sql)
        sql = substitute_variables(sql)
        execute_each_statement(sql, options)
      end
    end

    def error_occurred?
      @error_occurred
    end

    def clear_error_state
      @error_occurred = false
    end

    def drop_table_if_exists(table, options={})
      cascade = options.delete(:cascade) ? ' CASCADE' : ''
      execute("DROP TABLE IF EXISTS #{table}#{cascade};", options)
    end

    def drop_view_if_exists(view, options={})
      cascade = options.delete(:cascade) ? ' CASCADE' : ''
      execute("DROP VIEW IF EXISTS #{view}#{cascade};", options)
    end

    def table_exists?(schema, table)
      sql = <<-SQL
        SELECT count(*) FROM pg_tables
        WHERE schemaname = '#{schema}' AND tablename = '#{table}'
        ;
      SQL
      query(sql, :quiet => true).first['count'] == 1
    end

    private

    def fail_if_invalid_connection_credentials(host, port, database, user, password)
      fail ArgumentError, 'host needs to be a string' unless host.is_a?(String)
      fail ArgumentError, 'database needs to be a string' unless database.is_a?(String)
      fail ArgumentError, 'user needs to be a string' unless user.is_a?(String)
      fail ArgumentError, 'password needs to be a string' unless password.is_a?(String)
      fail ArgumentError, 'port needs to be a integer' unless port.to_s =~ /\A\d+\z/
    end

    def init_connection
      with_error_handling do
        @conn = PGconn.open(
          :host => @host,
          :port => @port,
          :dbname => @database,
          :user => @user,
          :password => @password,
        )
      end
    end

    # errors_to_ignore should only be used where no return value is expected
    def with_error_handling
      return_value = yield
      @retry_count = 0
      return_value

    rescue PG::Error => e
      if recoverable_error?(e.message) && @retry_count < @max_retries
        @retry_count += 1
        sleep_time = sleep_time_for_error(e.message)
        log "Failed with recoverable error (#{e.class}): #{e.message}"
        log "Retry attempt #{@retry_count} will occur after #{sleep_time} seconds"
        sleep sleep_time
        retry

      else
        @retry_count = 0
        @error_occurred = true
        log "An error occurred (#{e.class}): #{e.message}"
        log e.backtrace.join("\n")

        raise e if @abort_on_error
      end
    end

    def recoverable_error?(err_msg)
      false
    end

    def sleep_time_for_error(err_msg)
      60
    end

    def sql_exception_class
      fail NotImplementedError, 'sql_exception_class'
    end

    def remove_comments(sql)
      lines = sql.split("\n")
      stripped_lines = lines.reject {|line| starts_with_double_dash?(line) }
      stripped_lines.join("\n")
    end

    def starts_with_double_dash?(line)
      line =~ /\A\s*--/
    end

    def substitute_variables(sql)
      sql
    end

    def execute_each_statement(sql, options={})
      sql.split(/;\s*$/).each do |statement|
        execute("#{statement};", options)
      end
    end

    def log(msg)
      @logger.log(msg)
    end
  end
end
