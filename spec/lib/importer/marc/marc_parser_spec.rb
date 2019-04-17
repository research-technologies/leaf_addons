# frozen_string_literal: true

require 'spec_helper'
require 'importer'

RSpec.describe Importer::Marc::MarcParser do
  let(:fixture_path) { 'spec/fixtures' }
  let(:file) { "#{fixture_path}/marc/bib-3296.utf8" }
  let(:parser) { described_class.new(file) }

  # rubocop:disable Metrics/LineLength
  it 'returns the full set of attributes for the fixture' do
    expect(parser.first).to eq(
      title: ["Papers from the conference 'Community development in health : addressing the confusions', held at the King's Fund Centre on 13 June 1984."],
      pagination: ["39p."],
      creator: ["King Edward's Hospital Fund for London.  King's Fund Centre", "Community Health Initiatives Resource Unit", "London Community Health Resource"],
      id: "000003296",
      model: "PublishedWork",
      resource_type: ["Kfpub"],
      abstract: ["'Community Development in Health: Addressing the Confusions' was a one-day conference held at the King's Fund Centre on 13 June 1984, organised by the London Community Health Resource and the Community Health Initiatives Resource Unit, in collaboration with the King's Fund.  This report is a collection of papers given during the morning session.  It is hoped that this will provide a useful insight into current thinking on community development in health, and its role in influencing the health and health care of people in contemporary Britain.  For a more detailed account of community development in health from the afternoon session of the conference see: Community Development in Health: Addressing the Confusions by Gwynne Somerville (King's Fund/LCHR, 1985, £3.00)."],
      subject: ["Black & ethnic minorities", "Community development", "Evaluation", "Health"],
      place_of_publication: ["[London : King's Fund Centre, 1986]"], # this is bad data in the source!
    )
    # rubocop:enable Metrics/LineLength
  end
end
