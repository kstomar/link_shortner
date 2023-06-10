# frozen_string_literal: true

class ShortenedUrl < ApplicationRecord
  attr_accessor :custom_shortened_url

  belongs_to :user

  validates :url, presence: true, length: { minimum: 3, maximum: 255 }
  validates :shortened_url, presence: true, uniqueness: true, length: { minimum: 3, maximum: 255 }

  def active?
    expires_at > Time.current
  end
end
