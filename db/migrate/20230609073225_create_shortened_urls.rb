# frozen_string_literal: true

class CreateShortenedUrls < ActiveRecord::Migration[7.0]
  def change
    create_table :shortened_urls do |t|
      t.string :url
      t.string :shortened_url
      t.string :custom_shortened_url
      t.datetime :expires_at
      t.integer :clicks_count
      t.integer :user_id

      t.timestamps
    end
  end
end
