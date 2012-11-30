module CommentsHelper
  def date_readable_format(date_with_tz)
    DateTime.parse(date_with_tz).to_time.to_s
  end
end
