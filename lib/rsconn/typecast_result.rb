require 'bigdecimal'


module Rsconn
  class TypecastResult
    attr_reader :result

    TYPE_BOOLEAN = 16
    TYPE_BIGINT = 20
    TYPE_SMALLINT = 21
    TYPE_INTEGER = 23
    TYPE_OID = 26
    TYPE_REAL = 700
    TYPE_DOUBLE_PRECISION = 701
    TYPE_MONEY = 790
    TYPE_NUMERIC = 1700
    TYPE_DATE = 1082
    TYPE_TIMESTAMP_WITHOUT_TIME_ZONE = 1114
    TYPE_TIMESTAMP_WITH_TIME_ZONE = 1184

    def initialize(uncast_result)
      @uncast_result = uncast_result
      @result = uncast_result.map {|row| typecast_row(row) }
    end

    private

    def typecast_row(row)
      (0...@uncast_result.nfields).each do |index|
        column = @uncast_result.fname(index)
        type = @uncast_result.ftype(index)
        value = row[column]

        row[column] = typecast(type, value)
      end
      row
    end

    def typecast(type, value)
      case type

      when TYPE_BOOLEAN
        if value == 't'
          true
        elsif value == 'f'
          false
        else
          fail 'unexpected boolean string'
        end

      when TYPE_BIGINT, TYPE_SMALLINT, TYPE_INTEGER, TYPE_OID
        value.to_i

      when TYPE_REAL, TYPE_DOUBLE_PRECISION
        value.to_f

      when TYPE_MONEY, TYPE_NUMERIC
        BigDecimal.new(value)

      when TYPE_DATE, TYPE_TIMESTAMP_WITHOUT_TIME_ZONE, TYPE_TIMESTAMP_WITH_TIME_ZONE
        DateTime.strptime(value, '%Y-%m-%d %H:%M:%S')

      else
        value
      end
    end
  end
end
