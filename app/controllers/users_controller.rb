# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize_request, except: %i[create login]

  def create
    user = User.new(users_params)
    if user.save
      render json: user, serializer: UserSerializer, status: :created
    else
      render json: { error: 'User was not created.' }, status: :unprocessable_entity
    end
  end

  def login
    current_user = User.find_by_email(users_params[:email])
    if current_user&.authenticate(users_params[:password])
      token = JsonWebToken.encode(user_id: current_user.id)
      time = Time.now + 24.hours.to_i
      render json: { token: token, exp: time.strftime('%m-%d-%Y %H:%M'),
                     email: current_user.email }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  private

  def users_params
    params.require(:user).permit(:email, :password)
  end
end
