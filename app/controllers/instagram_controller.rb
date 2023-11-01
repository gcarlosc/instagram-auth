class InstagramController < ApplicationController
  # def connect
  #   redirect_to "https://api.instagram.com/oauth/authorize?client_id=#{ENV['INSTAGRAM_CLIENT_ID']}&redirect_uri=#{ENV['INSTAGRAM_REDIRECT_URI']}&scope=user_profile,user_media&response_type=code", allow_other_host: true
  # end

  def callback
    if params[:code]
      short_token = HTTParty.post('https://api.instagram.com/oauth/access_token',
        body: {
          client_id: ENV['INSTAGRAM_CLIENT_ID'],
          client_secret: ENV['INSTAGRAM_CLIENT_SECRET'],
          grant_type: 'authorization_code',
          redirect_uri: ENV['INSTAGRAM_REDIRECT_URI'],
          code: params[:code]
        }
      )

      res_long_token =
        if short_token = short_token['access_token']
          long_token = HTTParty.get('https://graph.instagram.com/access_token', query: {
            grant_type: 'ig_exchange_token',
            client_secret: ENV['INSTAGRAM_CLIENT_SECRET'],
            access_token: short_token
          })

        end

      session[:access_token] = res_long_token.parsed_response["access_token"]

      redirect_to sessions_path
    end
  end
end
