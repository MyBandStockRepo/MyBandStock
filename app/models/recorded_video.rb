class RecordedVideo < ActiveRecord::Base
  belongs_to :streamapi_stream
  
  def output_duration
    time = Time.at(self.duration).gmtime
    hour = time.hour

    if hour > 0
      return time.strftime('%H:%M:%S')
    else
      return time.strftime('%M:%S')
    end
  end

  def thumb_img
    return self.url.to_s+'.jpg'
  end
end
