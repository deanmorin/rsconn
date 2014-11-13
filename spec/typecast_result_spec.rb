require 'bigdecimal'
require 'rspec/its'
require 'rsconn/typecast_result'
require_relative 'custom_matchers'


module Rsconn
  class ResultStub < Array

    def initialize
      super(1)
    end

    def fname(index)
      self.first.keys[index]
    end

    def ftype(index)
      @ftypes[index]
    end

    def nfields
      self.first.keys.length
    end
  end

  class BooleanResultStub < ResultStub
    def initialize
      self[0] = { 'true' => 't', 'false' => 'f' }
      @ftypes = [TypecastResult::TYPE_BOOLEAN, TypecastResult::TYPE_BOOLEAN]
    end
  end

  class BadBooleanResultStub < ResultStub
    def initialize
      self[0] = { 'bad' => 'true' }
      @ftypes = [TypecastResult::TYPE_BOOLEAN]
    end
  end

  class IntegerResultStub < ResultStub
    def initialize
      self[0] = { 'c1' => '1', 'c2' => '2', 'c3' => '3', 'c4' => '4' }
      @ftypes = [
        TypecastResult::TYPE_BIGINT, TypecastResult::TYPE_SMALLINT,
        TypecastResult::TYPE_INTEGER, TypecastResult::TYPE_OID
      ]
    end
  end

  class FloatResultStub < ResultStub
    def initialize
      self[0] = { 'c1' => '-3', 'c2' => '4.111111111111111111' }
      @ftypes = [TypecastResult::TYPE_REAL, TypecastResult::TYPE_DOUBLE_PRECISION]
    end
  end

  class BigDecimalResultStub < ResultStub
    def initialize
      self[0] = { 'c1' => '-3', 'c2' => '4.11111111111111111111111111111111111111111111111111' }
      @ftypes = [TypecastResult::TYPE_MONEY, TypecastResult::TYPE_NUMERIC]
    end
  end

  class DateTimeResultStub < ResultStub
    def initialize
      self[0] = {
        'c1' => '1900-01-01 00:00:00',
        'c2' => '3000-01-01 01:00:00',
        'c3' => '4000-01-01 23:32:11'
      }
      @ftypes = [
        TypecastResult::TYPE_DATE,
        TypecastResult::TYPE_TIMESTAMP_WITHOUT_TIME_ZONE,
        TypecastResult::TYPE_TIMESTAMP_WITH_TIME_ZONE
      ]
    end
  end


  describe TypecastResult do

    describe '#new' do

      context "when there's booleans in the results" do
        subject { TypecastResult.new(BooleanResultStub.new) }
        let(:expected) { [{ 'true' => true, 'false' => false }] }
        its(:result) { is_expected.to eq(expected) }
      end

      context "when there's an bad boolean value in the results" do
        subject { TypecastResult.new(BadBooleanResultStub.new) }
        it { expect { subject }.to raise_error(RuntimeError) }
      end

      context "when there's integers in the results" do
        subject { TypecastResult.new(IntegerResultStub.new) }
        let(:expected) { [{ 'c1' => 1, 'c2' => 2, 'c3' => 3, 'c4' => 4 }] }
        its(:result) { is_expected.to eq(expected) }
        it { is_expected.to only_include_class(Fixnum) }
      end

      context "when there's floating point numbers in the results" do
        subject { TypecastResult.new(FloatResultStub.new) }
        let(:expected) { [{ 'c1' => -3, 'c2' => 4.111111111111111111.to_f }] }
        its(:result) { is_expected.to eq(expected) }
        it { is_expected.to only_include_class(Float) }
      end

      context "when there's large or non-arbitrary precision numbers in the results" do
        subject { TypecastResult.new(BigDecimalResultStub.new) }
        it { is_expected.to only_include_class(BigDecimal) }
      end

      context "when there's timestamps in the results" do
        subject { TypecastResult.new(DateTimeResultStub.new) }
        it { is_expected.to only_include_class(DateTime) }
      end
    end
  end
end
