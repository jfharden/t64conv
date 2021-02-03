require 'spec_helper'

require_relative '../../../../lib/t64conv/file_handlers/zip_file'

RSpec.describe T64conv::FileHandlers::ZipFileHandler do
  let(:tape_converter) { double }
  let(:dryrun) { false }

  describe '.zip_interesting?' do
    it 'returns false when uninteresting' do
      handler = described_class.new(zip_file_path('uninteresting.zip'), tape_converter, dryrun)
      expect(handler.zip_interesting?).to be false
    end

    tests = {
      'a T64 file' => 't64_in_subdir.zip',
      'a D64 file' => 'd64_file.zip',
      'multiple_files' => 'multiple_files.zip',
      'interesting files and the zip file name has a version number' => 'with_version (123).zip',
      'a zip file' => 'ZIP_FILE.ZIP',
    }

    tests.each do |file_contents, filename|
      it "returns true when the zip contains #{file_contents}" do
        handler = described_class.new(zip_file_path(filename), tape_converter, dryrun)
        expect(handler.zip_interesting?).to be false
      end
    end
  end

  def zip_file_path(filename)
    File.join('..', '..', '..', 'fixtures', 'zip_files', filename)
    File.join('spec', 'fixtures', 'zip_files', filename)
  end
end
