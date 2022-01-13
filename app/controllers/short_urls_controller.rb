require 'json'
class ShortUrlsController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  def index
    @short_urls = ShortUrl.order(click_count: :desc).limit(100)
    puts @short_urls.as_json

    render json: { :urls => @short_urls}, status: :ok

    #    respond_to do |format|
    #  format.json { render json: @short_urls, status: :ok}
    #end
  end

  def create
    @short_url = ShortUrl.create(full_url: params[:full_url])

    if (@short_url.errors.empty?)
      UpdateTitleJob.perform_later(@short_url.short_code)
      render json: @short_url, status: :created
    elsif
      render json: { :errors => @short_url.errors }, status: :bad_request
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
