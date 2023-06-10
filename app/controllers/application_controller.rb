# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def authorize_request
    header = request.headers['token']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  private

  def not_found
    render json: { 'errors' => ['Record not found'] }, status: :not_found
  end
end
