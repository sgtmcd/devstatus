require 'net/http'
class HomeController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index, :statuses]

  def index
    if request.post?
      @username = params[:username]
      session[:username] = @username
      @password = params[:password]
      if !params[:notice].strip().empty?
        post_notice(params[:username], params[:password], params[:notice])
      end
    end
    get_feeds
  end

  def statuses
    get_feeds
    @names.delete(session[:username]) if session[:username]
    render action: :index, layout: false
  end

  private
  def get_feeds
    feed = get_feed("http://10.1.28.92/statusnet/api/statuses/public_timeline.json", 'shawn', 'waterfield')
    @feeds = {}
    @names = {}
    feed.each { |f| @names[f['user']['name']] = true }
    @names = @names.keys.sort
    feed.each do |f|
      (@feeds[f["user"]["name"]] ||= []) << f
    end
  end
  def post_notice(user, pass, notice)
    parsed_url = URI.parse "http://10.1.28.92/statusnet/api/statuses/update.json"
    http = Net::HTTP.new(parsed_url.host)
    req = Net::HTTP::Post.new(parsed_url.path)
    req.basic_auth user, pass
    http.request(req, "status=#{notice}")
  end

  def get_feed(url, user, password)
    parsed_url = URI.parse url
    http = Net::HTTP.new(parsed_url.host)
    req = Net::HTTP::Get.new(parsed_url.path)
    req.basic_auth user, password
    req.set_content_type 'application/json'
    res  = http.request(req)
    res.read_body
    JSON.parse http.request(req).body
  end
end
