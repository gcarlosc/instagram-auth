class SessionsController < ApplicationController
  def index
    @access_token = session[:access_token_basic]
  end

  def callback
    if params[:code]
      short_token = HTTParty.post('https://api.instagram.com/oauth/access_token',
        body: {
          client_id: ENV['INSTAGRAM_CLIENT_ID_BASIC'],
          client_secret: ENV['INSTAGRAM_CLIENT_SECRET_BASIC'],
          grant_type: 'authorization_code',
          redirect_uri: ENV['INSTAGRAM_REDIRECT_URI_BASIC'],
          code: params[:code]
        }
      )

      res_long_token =
        if short_token = short_token['access_token']
          long_token = HTTParty.get('https://graph.instagram.com/access_token', query: {
            grant_type: 'ig_exchange_token',
            client_secret: ENV['INSTAGRAM_CLIENT_SECRET_BASIC'],
            access_token: short_token
          })

        end
      puts res_long_token
      session[:access_token_basic] = res_long_token.parsed_response["access_token"]
      redirect_to sessions_path
    else
      redirect_to sessions_path
    end
  end

  def user
    @token = session[:access_token_basic]
    uri = URI.parse("https://graph.instagram.com/me?fields=id,username,account_type,media_count,media&access_token=#{@token}")
    response = Net::HTTP.get_response(uri)
    @json_response = JSON.parse(response.body)
    @json_response["ir atrás"] = url_for(controller: 'sessions', action: 'index')
    render json: @json_response
  end

  def media
    @token = session[:access_token_basic]
    uri = URI.parse("https://graph.instagram.com/me/media?fields=caption,id,is_shared_to_feed,media_type,media_url,permalink,thumbnail_url,timestamp,username&access_token=#{@token}")
    response = Net::HTTP.get_response(uri)
    @json_response = JSON.parse(response.body)
    @json_response["ir atrás"] = url_for(controller: 'sessions', action: 'index')
    render json: @json_response
  end
end
