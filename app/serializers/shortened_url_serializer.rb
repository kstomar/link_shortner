# frozen_string_literal: true

class ShortenedUrlSerializer < ActiveModel::Serializer
  attributes :id, :url, :expires_at, :clicks_count, :shortened_url

  def shortened_url
    "#{scope}/#{object.shortened_url}"
  end
end
