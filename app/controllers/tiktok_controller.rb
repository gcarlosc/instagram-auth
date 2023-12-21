class TiktokController < ApplicationController
  def index
  end

  def tiktok_auth
    # tiktok_auth_url = URI.parse("https://open-api.tiktok.com/platform/oauth/connect/")
    # tiktok_auth_url.query = URI.encode_www_form(
    #   client_key: ENV['TIKTOK_CLIENT_ID_BASIC'],
    #   response_type: 'code',
    #   redirect_uri: ENV['TIKTOK_REDIRECT_URI_BASIC']
    # )

    # redirect_to tiktok_auth_url.to_s

    redirect_to "https://www.tiktok.com/v2/auth/authorize/?client_key=#{ENV['TIKTOK_CLIENT_ID_BASIC']}&response_type=code&redirect_uri=#{CGI.escape(callback_url)}&scope=user.info.basic"
  end

  def create
    code = params[:code]

    response = HTTParty.post('https://open-api.tiktok.com/oauth/access_token/',
      body: {
        client_key: ENV['TIKTOK_CLIENT_ID_BASIC'],
        client_secret: ENV['TIKTOK_CLIENT_ID_BASIC'],
        code: code,
        redirect_uri: callback_url,
        grant_type: 'authorization_code'
      }
    )

    token_info = JSON.parse(response.body)
    session[:user_id] = token_info['open_id']
    redirect_to root_path
  end

  def destroy
    session[:tiktok_token] = nil
    redirect_to root_path
  end

  private

  def callback_url
    "#{request.base_url}/auth/tiktok/callback"
  end
end
