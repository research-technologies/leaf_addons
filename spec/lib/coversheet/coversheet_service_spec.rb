# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LeafAddons::CoversheetService do
  let(:cover) { described_class.new(file_set) }
  let(:file_set) { instance_double(FileSet) }
  let(:book) { FactoryBot.create(:published_work) }
  let(:original_file) { instance_double(Hydra::PCDM::File) }
  let(:pdf) { 'spec/fixtures/testfile.pdf' }

  describe '#coversheetable?' do
    before do
      allow(file_set).to receive(:parent).and_return(book)
      allow(LeafAddons::CoversheetDerivativePath).to receive(:derivative_path_for_reference).with(file_set, 'service_file').and_return('/some/path')
      allow(cover).to receive(:file_path).and_return('/some/path')
      allow(file_set).to receive(:original_file).and_return(original_file)
    end

    it 'returns false if the file_path is nil' do
      allow(LeafAddons::CoversheetDerivativePath).to receive(:derivative_path_for_reference).with(file_set, 'service_file').and_return(nil)
      allow(cover).to receive(:file_path).and_return(nil)

      expect(cover.coversheetable?).to eq(false)
    end

    it 'returns true if the service file exists' do
      allow(File).to receive(:exist?).with('/some/path').and_return(true)

      expect(cover.coversheetable?).to eq(true)
    end

    it 'returns true and sets the file_url if there is no service_file and the original_file is a pdf' do
      allow(File).to receive(:exist?).with('/some/path').and_return(false)
      allow(original_file).to receive(:mime_type).and_return('application/pdf')
      allow(original_file).to receive(:uri).and_return('file_url')

      expect(cover.coversheetable?).to eq(true)
    end

    it 'returns false if there is no service_file and the original_file is a not a pdf' do
      allow(File).to receive(:exist?).with('/some/path').and_return(false)
      allow(original_file).to receive(:mime_type).and_return('text/plain')

      expect(cover.coversheetable?).to eq(false)
    end
  end

  describe '#with_coversheet' do
    it 'creates a file with the coversheet' do
      allow(cover).to receive(:file_path).and_return(pdf)
      allow(cover).to receive(:coversheetable?).and_return(true)
      allow(LeafAddons::CoversheetDerivativePath).to receive(:derivative_path_for_reference).with(file_set, 'service_file').and_return(pdf)
      allow(cover).to receive(:logo).and_return('spec/fixtures/coversheet_logo.png')
      allow(cover).to receive(:work).and_return(book)
      allow(file_set).to receive(:id).and_return('file_set_id')
      allow(book).to receive_messages(
        creator: [],
        title: [],
        license: [],
        abstract: [],
        publication_status: [],
        doi: [],
        official_url: [],
        resource_type: ['Book'],
        publisher: [],
        date_uploaded: nil
      )
      cover.with_coversheet

      expect(File.exist?('spec/fixtures/testfile_withcover.pdf')).to eq(true)
    end

    after do
      File.delete('spec/fixtures/testfile_withcover.pdf')
    end
  end
end
