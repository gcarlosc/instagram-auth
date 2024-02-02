class TiktokController < ApplicationController
  def index
  end

  def tiktok_auth
    # redirect_to "https://www.tiktok.com/v2/auth/authorize/?client_key=#{ENV['TIKTOK_CLIENT_ID_BASIC']}&response_type=code&scope=user.info.basic&redirect_uri=#{CGI.escape(callback_url)}&state=12345"

    redirect_uri = "https://188a-38-25-34-48.ngrok-free.app/auth/callback"
    redirect_to "https://www.tiktok.com/v2/auth/authorize/?client_key=awzwhc2xwwnhgt91&scope=user.info.basic,video.list&response_type=code&redirect_uri=https://188a-38-25-34-48.ngrok-free.app/auth/callback&state=#{SecureRandom.alphanumeric(6)}"
  end

  def create
    code = params[:code]

    response = HTTParty.post(
      'https://open-api.tiktok.com/oauth/access_token/',
      body: {
        client_key: ENV['TIKTOK_CLIENT_ID_BASIC'],
        client_secret: ENV['TIKTOK_CLIENT_SECRET_BASIC'],
        code: code,
        redirect_uri: callback_url,
        grant_type: 'authorization_code'
      }
    )

    token_info = JSON.parse(response.body)
    session[:tiktok_token] = token_info['access_token']
    redirect_to tiktok_index_path
  end

  def destroy
    session[:tiktok_token] = nil
    redirect_to tiktok_index_path
  end

  def research_token
    response = HTTParty.post(
      'https://open.tiktokapis.com/v2/oauth/token/',
      body: {
        client_key: ENV['TIKTOK_CLIENT_ID_BASIC'],
        client_secret: ENV['TIKTOK_CLIENT_SECRET_BASIC'],
        grant_type: 'client_credentials'
      }
    )

    token_info = JSON.parse(response.body)
    Rails.logger.info token_info
    session[:tiktok_token_client] = token_info['access_token']
    redirect_to tiktok_index_path
  end

  def research_api
    response = HTTParty.post(
      'https://open.tiktokapis.com/v2/research/user/info/',
      headers: {
        'Authorization' => "Bearer #{session[:tiktok_token_client]}",
        'Content-Type' => 'application/json'
      },
      query: {
        'fields' => 'display_name,bio_description,avatar_url,is_verified,follower_count,following_count,likes_count,video_count'
      },
      body: {
        username: 'mrcarlitus'
      }
    )
    binding.pry

    @user_info = JSON.parse(response.body)
    redirect_to tiktok_index_path
  end

  private

  def callback_url
    "#{request.base_url}/auth/callback/"
  end
end
# https://www.tiktok.com/v2/auth/authorize/?client_key=awzwhc2xwwnhgt91&response_type=code&redirect_uri=https://80b8-38-25-34-48.ngrok-free.app/auth/callback&scope=user.info.basic,user.info.profile,user.info.stats

# https://www.tiktok.com/v2/auth/authorize/?client_key=awzwhc2xwwnhgt91&response_type=code&redirect_uri=https%3A%2F%2F80b8-38-25-34-48.ngrok-free.app%2Fauth%2Fcallback&scope=user.info.basic,user.info.profile,user.info.stats


# https://188a-38-25-34-48.ngrok-free.app

# https://www.tiktok.com/v2/auth/authorize/?client_key=awzwhc2xwwnhgt91&scope=user.info.basic,video.list&response_type=code&redirect_uri=https://188a-38-25-34-48.ngrok-free.app/auth/callback&state=e9oN67

# https://www.tiktok.com/v2/auth/authorize/?client_key=aw07rq7oegt1uq40&scope=user.info.basic,video.list&response_type=code&redirect_uri=https://popsters.ru/api/com-token/tt/access&state=lhjnb9
