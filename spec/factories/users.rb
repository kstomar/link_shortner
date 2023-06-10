# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "#{Faker::Name}@example.com" }
    password { 'Password' }
  end
end
