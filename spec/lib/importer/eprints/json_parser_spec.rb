# frozen_string_literal: true

require 'importer'

RSpec.describe Importer::Eprints::JsonParser do
  let(:fixture_path) { 'spec/fixtures' }

  before do
    stub_request(:get, /.*/)
      .to_return(status: 200, body: "", headers: {})
  end

  describe 'with stubbed downloads returning empty files' do
    let(:file) { "#{fixture_path}/eprints_json/eprints.json" }
    let(:parser) { described_class.new(file, '/tmp') }

    after do
      Dir["/tmp/6289/*.*"].each { |file| File.delete(file) }
    end

    it 'returns the full set of attributes for the fixture' do
      expect(parser.first).to eq(
        former_id: ["6289"],
        id: "628900000",
        keyword: ["Building design", "Corridors"],
        publication_status: ["pub"],
        publisher: ["King Edward's Hospital Fund for London"],
        note: ["Pagination: 132p."],
        refereed: [true],
        editor: ["Holroyd, W. A. H."],
        abstract: ["This document originates ..."],
        resource_type: ["Kfpub"],
        title: ["Hospital traffic and supply problems"],
        creator: ["King Edward's Hospital Fund for London",
                  "Hospital Design Unit (Ministry of Health, Great Britain)"],
        pagination: ["132"],
        place_of_publication: ["London"],
        date_published: ["1968"],
        visibility: "open",
        model: "PublishedWork"
      )
    end

    it 'calls download once' do
      expect(parser).to receive(:download).exactly(1).times
      expect(File).not_to be_exist('/tmp/downloads.csv')
      parser.first
    end
  end

  describe 'validates checksum with fixture file' do
    let(:file_checksum) { "#{fixture_path}/eprints_json/eprints_validchecksum.json" }
    let(:parser_checksum) { described_class.new(file_checksum, '/tmp') }

    before do
      File.write('/tmp/6289/1119_006289.txt', '')
    end

    it 'writes the downloaded_files.csv file' do
      parser_checksum.first
      expect(File).to be_exist('/tmp/downloaded_files.csv')
      expect(File.read('/tmp/downloaded_files.csv')).to eq("628900000,1119_006289.txt,\n628900000,1120_006289.pdf,\n628900000,1119_indexcodes.txt,restricted\n")
    end

    it 'writes the import_files.csv file' do
      parser_checksum.first
      expect(File).to be_exist('/tmp/import_files.csv')
      expect(File.read('/tmp/import_files.csv')).to eq("628900000,6289\n")
    end

    after do
      Dir["/tmp/6289/*.*"].each { |file| File.delete(file) }
      File.delete('/tmp/downloaded_files.csv')
      File.delete('/tmp/import_files.csv')
    end
  end
end
