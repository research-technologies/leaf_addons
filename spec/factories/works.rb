# frozen_string_literal: true

FactoryBot.define do
  factory :published_work do
    title ['A published work']
    id 'test_id'
    publisher ['joyful publisher']
    date_published ['1999']
    place_of_publication ['Sheffield']
    doi ['doi']
    creator ['lovely, author']
  end

  factory :journal_article do
    title ['An article']
    id 'test_id_1'
    part_of ['journal']
    date_published ['1999']
    volume_number ['50']
    issue_number ['5']
    pagination ['1-10']
    doi ['doi']
    creator ['lovely, author']
  end

  factory :conference_item do
    title ['A conference paper']
    id 'test_id_2'
    presented_at ['conference']
    event_date ['1998']
    date_published ['1999']
    doi ['doi']
    creator ['lovely, author']
  end
end
