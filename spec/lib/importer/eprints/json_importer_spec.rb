# frozen_string_literal: true

require 'importer'

RSpec.describe Importer::Eprints::JsonImporter do
  let(:metadata_file) { 'spec/fixtures/eprints_json/eprints.json' }
  let(:importer) { described_class.new(metadata_file, '/tmp') }
  let(:actor) { double }
  let(:published_work_factory) { double }

  before do
    allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)

    stub_request(:get, /.*/)
      .to_return(status: 200, body: "", headers: {})
  end

  it 'creates an object' do
    expect(importer).to receive(:create_fedora_objects).exactly(1).times
    importer.import_all
  end

  it 'uses the published item factory, ie. the model is correctly set' do
    expect(Importer::Factory::PublishedWorkFactory).to receive(:new)
      .with(hash_including(id: '628900000'))
      .and_return(published_work_factory)
    expect(published_work_factory).to receive(:run)
    importer.import_all
  end
end
