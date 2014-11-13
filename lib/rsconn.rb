require 'rsconn/postgres'


module Rsconn
  class Redshift < Postgres
    attr_reader :query_group, :query_slot_count

    def initialize(jdbc_url, user, password, options={})
      super
      @query_group = options.fetch(:query_group, nil)
      @query_slot_count = options.fetch(:query_slot_count, nil)

      set_query_group(@query_group) if @query_group
      set_query_slot_count(@query_slot_count) if @query_slot_count
    end

    def set_query_group(query_group)
      execute("SET query_group TO #{query_group};")
    end

    def set_query_slot_count(count)
      execute("SET wlm_query_slot_count TO #{count};")
    end
  end
end
