module Rsconn
  RSpec::Matchers.define :only_include_class do |klass|
    match do |actual|
      actual.result.all? {|row| row.keys.all? {|key| row[key].class == klass } }
    end

    failure_message do |actual|
      "expected every value's class to be '#{klass}'"
    end
  end
end
