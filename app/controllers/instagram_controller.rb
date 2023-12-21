class InstagramController < ApplicationController

  def callback
  end

  def access
    # obtener el long lived token
    short_lived_token = params[:access_token]
    oauth = Koala::Facebook::OAuth.new(ENV['INSTAGRAM_CLIENT_ID_GRAPH'], ENV['INSTAGRAM_CLIENT_SECRET_GRAPH'])
    new_access_info = oauth.exchange_access_token_info(short_lived_token)
    long_lived_token = new_access_info["access_token"]
    expires_at = DateTime.now + new_access_info["expires_in"].to_i.seconds
    session[:access_token_graph] = long_lived_token

    # obtener el primer instagram account por ahora
    @graph = Koala::Facebook::API.new(long_lived_token)
    data = @graph.get_object('me/accounts', fields: 'instagram_business_account')
    insta_account = get_first_instagram_business_account_id(data)
    session[:insta_account] = insta_account
  end

  def index
    @access_token = session[:access_token_graph]
    @insta_account = session[:insta_account]
  end

  def user_info
    graph = Koala::Facebook::API.new(session[:access_token_graph])
    res = graph.get_object(session[:insta_account], fields: 'biography,id,ig_id,followers_count,follows_count,media_count,name,profile_picture_url,username,website')
    res["ir atrás"] = url_for(controller: 'instagram', action: 'index')
    render json: res
  end

# ?metric=engaged_audience_demographics&period=lifetime&metric_type=total_value&timeframe=last_90_days&breakdown=age
  def user_insights
    graph = Koala::Facebook::API.new(session[:access_token_graph])
    fields_user = 'id,name,username,profile_picture_url,biography,followers_count,follows_count,media_count,stories,
    insights.metric(impressions,reach).period(day)'
    fields_demo = 'insights.metric(impressions,reach).period(day)'
    fields_user_res = graph.get_object(session[:insta_account], { fields: fields_user })
    fields_demo_res = graph.get_object('17841462527107856/insights', {
      metric: 'engaged_audience_demographics',
      metric_type: 'total_value',
      period: 'lifetime',
      timeframe: 'last_30_days',
      breakdown: 'age'
    })
    x = fields_demo_res.unshift(fields_user_res)
    x << { 'ir atrás': url_for(controller: 'instagram', action: 'index') }
    render json: x
  end

  def media_insights
    graph = Koala::Facebook::API.new(session[:access_token_graph])
    fields = 'id,caption,media_type,media_url,permalink,thumbnail_url,like_count,comments_count,timestamp,
              comments{id,text,username,like_count,replies{id,username,like_count,text}},
              insights.metric(impressions,reach,comments,follows,likes,shares){name,period,description,values}'
    insights = graph.get_object("#{session[:insta_account]}/media", { fields: fields })
    insights << { 'ir atrás': url_for(controller: 'instagram', action: 'index') }
    render json: insights
  end

  private

  def get_first_instagram_business_account_id(data)
    data.each do |item|
      if item['instagram_business_account']
        return item['instagram_business_account']['id']
      end
    end
    nil
  end
end

