class SessionsController < ApplicationController
  def index
  end

  def user
    @token = session[:access_token]
    uri = URI.parse("https://graph.instagram.com/me?fields=id,username,account_type,media_count,media&access_token=#{@token}")
    response = Net::HTTP.get_response(uri)
    @json_response = JSON.parse(response.body)
    render json: @json_response
  end

  def media
    @token = session[:access_token]
    uri = URI.parse("https://graph.instagram.com/me/media?fields=caption,id,is_shared_to_feed,media_type,media_url,permalink,thumbnail_url,timestamp,username&access_token=#{@token}")
    response = Net::HTTP.get_response(uri)
    @json_response = JSON.parse(response.body)
    render json: @json_response
  end


  # def create
  #   auth = request.env["omniauth.auth"]
  #   user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
  #   session[:user_id] = user.id
  #   redirect_to root_url, :notice => "Signed in!"
  # end
end
