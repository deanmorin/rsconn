# rsconn

A convenience wrapper to make interaction with a Redshift cluster easier.

## Installation

Add this line to your application's Gemfile:

    gem 'rsconn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rsconn

## Usage

This is an example of connecting to and using a Redshift database using a JDBC URL.

    require 'rsconn'

    url = Rsconn::JdbcUrl.new(ENV['RSCONN_JDBC_URL'])

    db_conn = Rsconn::Redshift.new(
      url.host,
      url.port,
      url.database,
      ENV['RSCONN_USER'],
      ENV['RSCONN_PASSWORD'],
    )

    # For updates, inserts, deletes, etc., use #execute.
    db_conn.execute('CREATE TABLE reg.students (id integer, name varchar(100))')
    db_conn.execute("INSERT INTO reg.students VALUES (1, 'Dean')")

    # Queries return an easy to use data structure - there's no need to manually
    # create and iterate through cursors
    rows = db_conn.query('SELECT * FROM reg.students WHERE id = 1')

    puts "Use the column name: #{rows.first['name']}"
    puts "Or use the column index: {rows.first[1]}"

    # To run non-query SQL statements from a script, use #execute_script

## Contributing

1. Fork it ( https://github.com/deanmorin/rsconn/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Running tests

The tests need to connect to a Redshift cluster. Set the environment variables `RSCONN_JDBC_URL`, `RSCONN_USER`, `RSCONN_PASSWORD` and make sure the cluster has a `test` schema.
