# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShortenedUrlsController, type: :controller do
  let(:user) { create(:user) } # You should define the 'create' factory method in your test suite

  describe 'GET #index' do
    context 'when authorized' do
      before do
        token = JsonWebToken.encode(user_id: user.id)
        request.headers['token'] = "Bearer #{token}"
      end

      it 'returns a list of shortened urls ordered by clicks_count' do
        shortened_url1 = create(:shortened_url, user: user, clicks_count: 5)
        shortened_url2 = create(:shortened_url, user: user, clicks_count: 3)

        get :index

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(shortened_url1.url, shortened_url2.url)
        expect(response.body.index(shortened_url1.url)).to be < response.body.index(shortened_url2.url)
      end
    end

    context 'when unauthorized' do
      before do
        request.headers['token'] = nil
      end

      it 'returns unauthorized status' do
        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include('Nil JSON web token')
      end
    end
  end
  describe 'GET show' do
    before do
      token = JsonWebToken.encode(user_id: user.id)
      @shortened_url = create(:shortened_url, user: user, clicks_count: 5)
      request.headers['token'] = "Bearer #{token}"
    end

    # before { get :show, params: { id: shortened_url.id }, headers: headers }

    context 'when authorized request' do
      it 'returns a successful response' do
        get :show, params: { id: @shortened_url.id }
        expect(response).to be_successful
      end

      it 'returns a not found shortened url' do
        get :show, params: { id: 6 }
        expect(response.body).to include('Record not found')
      end
    end
  end

  describe 'GET redirect_to_main_url' do
    let(:shortened_url) { create(:shortened_url, user: user) }
    let(:expired_shortened_url) { create(:expired_shortened_url, user: user) }

    context 'when valid shortened url is provided' do
      before { get :redirect_to_main_url, params: { short_url: shortened_url.shortened_url } }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'increments the clicks count of the shortened url' do
        expect(shortened_url.reload.clicks_count).to eq(1)
      end

      it 'redirects to the original url' do
        expect(response.body).to include(shortened_url.url)
      end
    end

    context 'when expired shortened url is provided' do
      before { get :redirect_to_main_url, params: { short_url: expired_shortened_url.shortened_url } }

      it 'returns a 404 error response' do
        expect(response).to have_http_status(404)
      end

      it 'returns an error message in the response' do
        expect(JSON.parse(response.body)['message']).to eq('Shortened URL not found or expired.')
      end
    end

    context 'when invalid shortened url is provided' do
      before { get :redirect_to_main_url, params: { short_url: 'invalid_shortened_url' } }

      it 'returns a 404 error response' do
        expect(response).to have_http_status(404)
      end

      it 'returns an error message in the response' do
        expect(JSON.parse(response.body)['message']).to eq('Shortened URL not found or expired.')
      end
    end
  end

  describe 'POST #create' do
    before do
      token = JsonWebToken.encode(user_id: user.id)
      request.headers['token'] = "Bearer #{token}"
    end

    let(:valid_attributes) { attributes_for(:shortened_url) }
    let(:invalid_attributes) { { url: '' } }

    context 'with valid params' do
      it 'creates a new ShortenedUrl' do
        expect do
          post :create, params: { shortened_url: valid_attributes }
        end.to change(ShortenedUrl, :count).by(1)
      end

      it 'renders a JSON response with the new shortened_url' do
        post :create, params: { shortened_url: valid_attributes }
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new shortened_url' do
        post :create, params: { shortened_url: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('application/json')
        expect(JSON.parse(response.body)['message']).to eq('Unable to create Shortened URL.')
      end
    end
  end
end
