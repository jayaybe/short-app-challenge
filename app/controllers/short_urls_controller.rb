require 'json'
class ShortUrlsController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  def index
    @short_urls = ShortUrl.order(click_count: :desc).limit(100)
    render json: { :urls => @short_urls}, status: :ok
  end

  def create
    @short_url = ShortUrl.create(full_url: params[:full_url])

    if (@short_url.errors.empty?)
      UpdateTitleJob.perform_later(@short_url.id)
      render json: @short_url, status: :created
    elsif
      # !!! -- find a way to unpack @short_url.errors.values into something rspec will recognize.
      #render json: { :errors => "Full url is not a valid url"}, status: :bad_request
      render json: { :errors => @short_url.errors.values }, status: :bad_request
    end
  end

  def show
    begin
      @short_url = ShortUrl.find_by_short_code(params[:id])
      @short_url.update(click_count: @short_url[:click_count] + 1)
      redirect_to @short_url[:full_url]
    rescue StandardError
      render json: "", status: :not_found
    end
  end

end
