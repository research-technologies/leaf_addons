  require 'importer'
require 'importer/eprints'

RSpec.describe Importer::Eprints::JsonParser do
  let(:parser) { described_class.new(file) }
  let(:attributes) { parser.attributes }
  let(:file) { "#{fixture_path}/eprints_json/eprints.json" }
  let(:first_record) { parser.first }

  it 'returns the full set of attributes for the fixture' do
    stub_request(:get, /.*/)
      .to_return(status: 200, body: "", headers: {})

    expect(first_record).to eq(
      former_id: ["6289"],
      id: "ep0006289",
      keyword: ["Building design",
                "Corridors",
                "Efficiency",
                "Escalators",
                "Food distribution",
                "Hospital supplies",
                "Lifts",
                "Meal services",
                "Storage furniture"],
      pulication_status: "pub",
      publisher: ["King Edward's Hospital Fund for London"],
      description: ["Pagination: 132p."],
      refereed: true,
      editor: ["Holroyd, W. A. H."],
      abstract: ['This document originates from a one-day conference and its purpose is to ' \
                      'report on studies of issues and options in the field of hospital traffic ' \
                      'and supply which were carried out within the context of the Greenwich ' \
                      'District Hospital development project which was seen as a laboratory ' \
                      'situation in which new ideas could be tested and assessed. The particular ' \
                      'issues covered in this document are: the purpose of a hospital building ' \
                      'and different types of layouts; the movement of people vertically by lifts ' \
                      'and escalators, and horizontally along corridors; the movement of goods ' \
                      'and the collection of items for disposal or reprocessing; the supply of ' \
                      'meals; the storage of goods.'],
      resource_type: ["kfpub"],
      title: ['Hospital traffic and supply problems : a report of studies undertaken by members ' \
                   'of the Hospital Design Unit of the Ministry of Health within ' \
                   'the context of the Greenwich District Hospital development project'],
      creator: ["King Edward's Hospital Fund for London", "Hospital Design Unit (Ministry of Health, Great Britain)"],
      pagination: "132",
      place_of_publication: ["London"],
      date_published: "1968",
      visibility: "open",
      model: "PublishedWork",
      remote_files: [{ file_name: "006289.txt", url: "http://some.url.org/6289/1/006289.txt" },
                     { file_name: "006289.pdf", url: "http://some.url.org/6289/2/006289.pdf" }],
      files_hash: { "006289.txt" =>
                          { additional_files: [
                            { file_name: "indexcodes.txt",
                              url: "http://some.url.org/6289/3/indexcodes.txt",
                              type: "extracted_text" }
                          ] },
                    "006289.pdf" => {} }
    )
  end
end
