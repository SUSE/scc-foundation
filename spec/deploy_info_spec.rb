# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "time"
require "scc/deploy_info"

RSpec.describe Scc::DeployInfo do
  let(:stubbed_info) { {} }
  let(:extractor) { double("Extractor", call: stubbed_info) }
  let(:obj) { described_class.new(extractor:).extract! }

  describe "#short_sha" do
    let(:stubbed_info) { {commit_sha: "abcdefgh"} }

    it "returns 8-character short sha" do
      expect(obj.short_sha).to eq("abcdefgh")
    end

    context "when commit sha is just numbers" do
      let(:stubbed_info) { {commit_sha: 44_364_843} }

      it "returns 8-character short sha" do
        expect(obj.short_sha).to eq("44364843")
      end
    end

    context "when commit sha is shorter than 8 characters" do
      let(:stubbed_info) { {commit_sha: "44"} }

      it "returns up to 8-characters short sha" do
        expect(obj.short_sha).to eq("44")
      end
    end

    context "when commit sha is not present" do
      let(:stubbed_info) { {commit_sha: nil} }

      it "returns up UNKNOWN" do
        expect(obj.short_sha).to eq("UNKNOWN")
      end
    end
  end

  describe "#commit_date" do
    let(:dt) { DateTime.now }
    let(:stubbed_info) { {commit_date: dt} }

    it "returns the date" do
      expect(obj.commit_date).to eq(dt)
    end

    it "formats the date" do
      expect(obj.formatted_date).to eq(dt.strftime("%d %b %Y %H:%M"))
    end

    context "when commit date is nil" do
      let(:stubbed_info) { {commit_date: nil} }

      it "returns unknown" do
        expect(obj.commit_date).to eq("UNKNOWN")
      end
    end

    context "when commit date is a string" do
      let(:stubbed_info) { {commit_date: "a string value"} }

      it "returns it as-is" do
        expect(obj.commit_date).to eq("a string value")
      end
    end

    context "when commit date is not a valid type" do
      let(:stubbed_info) { {commit_date: 1234} }

      it "returns up to 8-characters short sha" do
        expect { obj.commit_date }.to raise_error(ArgumentError)
      end
    end
  end

  %i[deploy_ref commit_sha commit_subject].each do |static_field|
    describe "##{static_field}" do
      let(:stubbed_info) { {static_field => "value"} }

      it "returns the value as-is" do
        expect(obj.send(static_field)).to eq("value")
      end

      context "when ##{static_field} is not present" do
        let(:stubbed_info) { {} }

        it "returns unknown" do
          expect(obj.send(static_field)).to eq("UNKNOWN")
        end
      end
    end
  end

  describe "#version_string" do
    context "when everything is unknown" do
      let(:stubbed_info) { {} }

      it "shows all unknown info" do
        expect(obj.version_string).to eq("UNKNOWN/UNKNOWN @ UNKNOWN")
      end
    end

    context "when date is passed" do
      let(:dt) { DateTime.parse("2024-01-22T08:28:07+00:00") }
      let(:stubbed_info) { {commit_date: dt} }

      it "shows the time right" do
        expect(obj.version_string).to eq("UNKNOWN/UNKNOWN @ 22 Jan 2024 08:28")
      end

      context "when date is empty" do
        let(:dt) { "" }

        it "shows unknown" do
          expect(obj.version_string).to eq("UNKNOWN/UNKNOWN @ UNKNOWN")
        end
      end
    end

    context "when everything is passed" do
      let(:dt) { DateTime.parse("2024-01-22T08:28:07+00:00") }
      let(:stubbed_info) do
        {
          deploy_ref: "da-branch",
          commit_date: dt,
          commit_sha: 44_364_843
        }
      end

      it "shows the full version string" do
        expect(obj.version_string).to eq("da-branch/44364843 @ 22 Jan 2024 08:28")
      end
    end
  end

  describe "#to_poro" do
    let(:dt) { DateTime.parse("2024-01-22T08:28:07+00:00") }
    let(:stubbed_info) do
      {
        deploy_ref: "da-branch",
        commit_subject: "a subject",
        commit_date: dt,
        commit_sha: 44_364_843,
        origin: :test
      }
    end

    it "returns a plain ruby hash with string keys" do
      expect(obj.to_poro).to be_kind_of(Hash)
      expect(obj.to_poro.keys).to all be_kind_of(String)
      expect(obj.to_poro.keys).to match_array(%w[deploy_ref commit_subject commit_date commit_sha origin])
    end
  end
end
