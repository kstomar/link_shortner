# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new user' do
        post :create, params: { user: { email: 'test@example.com', password: 'password' } }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['email']).to eq('test@example.com')
      end
    end

    context 'with invalid attributes' do
      it 'returns unprocessable_entity' do
        post :create, params: { user: { email: 'test@example.com' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('User was not created.')
      end
    end
  end

  describe 'POST #login' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password') }

    context 'with valid credentials' do
      it 'returns a token' do
        post :login, params: { user: { email: user.email, password: 'password' } }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['token']).to be_present
        expect(JSON.parse(response.body)['email']).to eq('test@example.com')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized' do
        post :login, params: { user: { email: user.email, password: 'wrong_password' } }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('unauthorized')
      end
    end
  end
end
