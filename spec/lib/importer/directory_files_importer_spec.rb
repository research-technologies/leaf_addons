# frozen_string_literal: true

require 'importer'

RSpec.describe Importer::DirectoryFilesImporter do

  let(:published_work_factory) {double}
  let(:fixture_path) { 'spec/fixtures' }

  before do
    FactoryBot.create(:published_work)
  end

  describe 'when depth 0 is passed' do
    let(:metadata_file) {"#{fixture_path}/directory/depth-0.csv"}
    let(:files_directory) {"#{fixture_path}/directory/depth-0"}
    let(:importer) {described_class.new(metadata_file, files_directory, 0)}

    it 'update published works with files' do
      expect(Importer::Factory::PublishedWorkFactory).to receive(:new)
                                                             .with(hash_including(:uploaded_files))
                                                             .with(hash_including(:id))
                                                             .and_return(published_work_factory)
      expect(published_work_factory).to receive(:run)
      importer.import_all
    end

    # after do
    #  File.delete("#{fixture_path}/directory/depth-0/uploaded_files.csv")
    # end
  end

  describe 'when depth 1 is passed' do
    let(:metadata_file) {"#{fixture_path}/directory/depth-1.csv"}
    let(:files_directory) {"#{fixture_path}/directory/depth-1"}
    let(:importer) {described_class.new(metadata_file, files_directory, 1)}

    it 'update published works with files from directory' do
      expect(Importer::Factory::PublishedWorkFactory).to receive(:new)
                                                             .with(hash_including(:uploaded_files))
                                                             .with(hash_including(:id))
                                                             .and_return(published_work_factory)
      expect(published_work_factory).to receive(:run)
      importer.import_all
    end

    # it 'writes the uploaded_files.csv file' do
    #  importer.import_all
    #  expect(File.read("#{files_directory}/uploaded_files.csv")).to eq("test_id,1,\n")
    # end

    # after do
    #  File.delete("#{fixture_path}/directory/depth-0/uploaded_files.csv")
    # end
  end
end
