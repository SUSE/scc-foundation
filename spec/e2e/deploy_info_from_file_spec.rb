# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "time"
require "scc/deploy_info"

RSpec.describe Scc::DeployInfo do
  describe ".from_file" do
    context "with a valid file" do
      let(:tmpfile) do
        Tempfile.new("deploy-info-sample").tap do |f|
          f.write(load_file_fixture("deploy_info/valid_deploy_info.yml"))
          f.close
        end
      end

      after { tmpfile.unlink }

      let(:obj) do
        described_class.from_file(filename: Pathname(tmpfile.path)).extract!
      end

      it "loads from deploy info file" do
        expect(obj.version_string).to eq("file_ref/file_sha @ 31 Jan 2022 16:47")
      end
    end

    context "with a valid file missing a key" do
      let(:tmpfile) do
        Tempfile.new("deploy-info-sample").tap do |f|
          f.write(load_file_fixture("deploy_info/valid_deploy_info_missing_a_key.yml"))
          f.close
        end
      end

      after { tmpfile.unlink }

      let(:obj) do
        described_class.from_file(filename: Pathname(tmpfile.path)).extract!
      end

      it "loads from deploy info file" do
        expect(obj.version_string).to eq("UNKNOWN/file_sha @ 31 Jan 2022 16:47")
      end
    end

    context "with an empty file" do
      let(:tmpfile) do
        Tempfile.new("deploy-info-empty").tap do |f|
          f.write("")
          f.close
        end
      end

      after { tmpfile.unlink }

      let(:obj) do
        described_class.from_file(filename: Pathname(tmpfile.path)).extract!
      end

      it "raises error" do
        expect { obj.version_string }.to raise_error(Scc::DeployInfo::Extractor::File::ManifestEmpty)
      end
    end

    context "with an bad shape file" do
      let(:tmpfile) do
        Tempfile.new("deploy-info-sample").tap do |f|
          f.write(load_file_fixture("deploy_info/bad_structure.yml"))
          f.close
        end
      end

      after { tmpfile.unlink }

      let(:obj) do
        described_class.from_file(filename: Pathname(tmpfile.path)).extract!
      end

      it "raises error" do
        expect { obj.version_string }.to raise_error(Scc::DeployInfo::Extractor::File::ManifestInvalid)
      end
    end

    context "with an invalid YAML file" do
      let(:tmpfile) do
        Tempfile.new("deploy-info-sample").tap do |f|
          f.write(load_file_fixture("deploy_info/invalid_yaml_syntax.yml"))
          f.close
        end
      end

      after { tmpfile.unlink }

      let(:obj) do
        described_class.from_file(filename: Pathname(tmpfile.path)).extract!
      end

      it "raises error" do
        expect { obj.version_string }.to raise_error(Scc::DeployInfo::Extractor::File::ManifestInvalid)
      end
    end
  end
end
