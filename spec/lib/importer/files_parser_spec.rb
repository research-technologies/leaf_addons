# frozen_string_literal: true

require 'importer'
require 'csv'

RSpec.describe Importer::FilesParser do
  let(:fixture_path) { 'spec/fixtures' }
  let(:metadata_file_1) { "#{fixture_path}/directory/depth-1.csv" }
  let(:files_directory_1) { "#{fixture_path}/directory/depth-1" }

  context 'when files at depth 0' do
    let(:parser_0) { described_class.new(metadata_file_0, files_directory_0, 0) }
    let(:metadata_file_0) { "#{fixture_path}/directory/depth-0.csv" }
    let(:files_directory_0) { "#{fixture_path}/directory/depth-0" }

    let(:first_record) { parser_0.first }

    it 'returns an array containing the id and an UploadedFile id for depth-0' do
      expect(first_record[0]).to eq('test_id')
      expect(first_record[1].length).to eq(1)
    end
  end

  context 'when files at depth 1' do
    let(:parser_1) { described_class.new(metadata_file_1, files_directory_1, 1) }
    let(:first_record) { parser_1.first }

    it 'returns an array containing the id and an UploadedFile id for depth-1' do
      expect(first_record[0]).to match('test_id')
      expect(first_record[1].length).to eq(1)
    end
  end

  context 'when files at depth 2' do
    let(:parser_2) { described_class.new(metadata_file_1, files_directory_1, 2) }
    let(:first_record) { parser_2.first }

    it 'returns an array containing the id and an empty array for depth 2' do
      expect(first_record[0]).to eq('test_id')
      expect(first_record[1]).to match([])
    end
  end
end
