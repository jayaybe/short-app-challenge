class UpdateTitleJob < ApplicationJob
  queue_as :default

  def perform(short_url_id)
    ShortUrl.find_by_short_code(short_url_id).update_title!
  end
end
