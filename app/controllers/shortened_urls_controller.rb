# frozen_string_literal: true

class ShortenedUrlsController < ApplicationController
  before_action :authorize_request, except: :redirect_to_main_url

  def index
    shortened_urls = @current_user.shortened_urls.order(clicks_count: :desc)
    render json: shortened_urls, each_serializer: ShortenedUrlSerializer, scope: request.base_url, status: :ok
  end

  def show
    shortened_url = ShortenedUrl.find(params[:id])
    render json: shortened_url, serializer: ShortenedUrlSerializer, scope: request.base_url, status: :ok
  end

  def create
    shortened_url = @current_user.shortened_urls.build(shortened_url_params)
    shortened_url.shortened_url = get_shortened_url

    shortened_url.expires_at = params[:shortened_url][:expires_at].to_i.days.after
    if shortened_url.save
      render json: shortened_url, serializer: ShortenedUrlSerializer, scope: request.base_url, status: :created
    else
      render json: { message: 'Unable to create Shortened URL.' }, status: :unprocessable_entity
    end
  end

  def redirect_to_main_url
    shortened_url = ShortenedUrl.find_by(shortened_url: params[:shortened_url])
    if shortened_url.present? && shortened_url.active?
      shortened_url.increment!(:clicks_count)
      render json: shortened_url.url, status: :ok
    else
      render json: { message: 'Shortened URL not found or expired.' }, status: 404
    end
  end

  private

  def get_shortened_url
    shortened_url_params[:custom_shortened_url].presence || generate_short_url
  end

  def generate_short_url
    short_url = SecureRandom.hex(3)
    short_url = SecureRandom.hex(3) while ShortenedUrl.exists?(shortened_url: short_url)
    short_url
  end

  def shortened_url_params
    params.require(:shortened_url).permit(:url, :custom_shortened_url, :expires_at)
  end
end
