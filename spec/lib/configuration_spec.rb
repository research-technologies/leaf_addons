# frozen_string_literal: true

RSpec.describe LeafAddons::Configuration do
  subject { described_class.new }

  # readers
  it { is_expected.to respond_to(:create_pdfs_on_ingest) }
  it { is_expected.to respond_to(:citation_style) }
  it { is_expected.to respond_to(:citation_mapping) }
  it { is_expected.to respond_to(:coversheet_blocks) }
  it { is_expected.to respond_to(:coversheet_blocks_in_order) }
  it { is_expected.to respond_to(:coversheet_image) }
  it { is_expected.to respond_to(:coversheet_spaces) }
  it { is_expected.to respond_to(:coversheet_font) }
  it { is_expected.to respond_to(:coversheet_fontsize_small) }
  it { is_expected.to respond_to(:coversheet_fontsize_large) }
  it { is_expected.to respond_to(:coversheet_indent) }
  it { is_expected.to respond_to(:coversheet_page_size) }
  it { is_expected.to respond_to(:coversheet_margin) }

  # writers
  it { is_expected.to respond_to(:create_pdfs_on_ingest=) }
  it { is_expected.to respond_to(:citation_style=) }
  it { is_expected.to respond_to(:citation_mapping=) }
  it { is_expected.to respond_to(:coversheet_blocks=) }
  it { is_expected.to respond_to(:coversheet_blocks_in_order=) }
  it { is_expected.to respond_to(:coversheet_image=) }
  it { is_expected.to respond_to(:coversheet_spaces=) }
  it { is_expected.to respond_to(:coversheet_font=) }
  it { is_expected.to respond_to(:coversheet_fontsize_small=) }
  it { is_expected.to respond_to(:coversheet_fontsize_large=) }
  it { is_expected.to respond_to(:coversheet_indent=) }
  it { is_expected.to respond_to(:coversheet_page_size=) }
  it { is_expected.to respond_to(:coversheet_margin=) }
end
