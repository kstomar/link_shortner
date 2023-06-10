# frozen_string_literal: true

FactoryBot.define do
  factory :shortened_url do
    url { Faker::Internet.url }
    shortened_url { SecureRandom.hex(3) }
    expires_at { 20.days.after }
  end

  factory :expired_shortened_url, class: 'ShortenedUrl' do
    url { Faker::Internet.url  }
    shortened_url { SecureRandom.hex(3) }
    expires_at { 1.day.ago }
  end
end
