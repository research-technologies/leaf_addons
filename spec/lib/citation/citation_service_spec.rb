# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LeafAddons::CitationService do
  let(:book_citation) { described_class.new(book) }
  let(:journal_citation) { described_class.new(article) }
  let(:conf_citation) { described_class.new(confpaper) }

  # create a citation and check it

  let(:book) { FactoryBot.create(:published_work) }
  let(:article) { FactoryBot.create(:journal_article) }
  let(:confpaper) { FactoryBot.create(:conference_item) }

  describe 'creates a citation for different formats' do
    it 'creates a book citation' do
      expect(book_citation.citation_item.type).to eq('book')
      expect(book_citation.render).to eq(["lovely, author. (1999). <i>A published work</i>. Sheffield: joyful publisher. https://doi.org/doi"])
    end
    it 'creates a journal citation' do
      expect(journal_citation.citation_item.type).to eq('article-journal')
      expect(journal_citation.render).to eq(["lovely, author. (1999). An article. <i>Journal</i>, <i>50</i>(5), 1–10. https://doi.org/doi"])
    end
    it 'creates a conference citation' do
      expect(conf_citation.citation_item.type).to eq('paper-conference')
      expect(conf_citation.render).to eq(["lovely, author. (1999). A conference paper. Presented at the conference. https://doi.org/doi"])
    end
  end

  describe 'creates a citation instead of a bibliography' do
    it 'renders a citation' do
      expect(journal_citation.render(:citation)).to eq("(lovely, 1999)")
    end
  end

  describe 'renders a differnt citation style' do
    before do
      LeafAddons.config.citation_style = 'harvard-cite-them-right'
    end
    it 'renders in harvard-cite-them-right style' do
      expect(journal_citation.render).to eq(["lovely, author (1999) “An article,” <i>journal</i>, 50(5), pp. 1–10. doi: doi."])
    end
  end
end
