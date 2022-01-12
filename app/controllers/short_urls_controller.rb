class ShortUrlsController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  def index
    #!!! --top 100 short URLs -- !!! format this
    ShortUrl.order(:click_count).limit(100)
  end

  def create
    #create a new short_url. format response
  end

  def show
    begin
      short_url = ShortUrl.find_by_short_code(params[:id])
      short_url.update(click_count: short_url[:click_count] + 1)
      redirect_to short_url[:full_url]
    rescue
      #!!! -- handle 404s
    end
  end

end
