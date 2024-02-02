require "scc/utils"

RSpec.describe Scc::Utils do
  describe "#try_parse_date" do
    subject { described_class.try_parse_date(input_value) }

    context "when input is string" do
      let(:input_value) { "2024-02-01T08:00:10" }

      it "parses to a datetime" do
        expect(subject).to be_kind_of(DateTime)
      end

      context "when the string is not a date" do
        let(:input_value) { "phrasing" }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end
    end

    context "when input is nil" do
      let(:input_value) { nil }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    [Date, DateTime, Time].each do |klass|
      context "when input is #{klass.name}" do
        let(:input_value) { klass.new }

        it "returns it as-is" do
          expect(subject).to be(input_value)
        end
      end
    end
  end
end
