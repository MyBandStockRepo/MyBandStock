class CallbacksController < ApplicationController
  respond_to :html, :xml
  skip_before_filter :verify_authenticity_token # Disable CSRF protection for incoming POST requests here

  def test  
  end
  
  def streamapi
    #get the action from the raw post
    post_arr = request.raw_post.split('&')
    action_str = ""
    Rails.logger.warn "\nRAW - #{post_arr}\n"
    post_arr.each do |one_str|
      if one_str.include?('action=')
        action_str = one_str
      end
    end
    @response_hash = case action_str
      when 'action=login'
        streamapi_authenticate_user(params)
      when 'action=end_live'
        streamapi_live_stream_finished(params)
      when 'action=end_record'
        streamapi_recording_transcode_finished(params)
    end

    render :layout => false
  end


private

  def streamapi_authenticate_user(params)
    options_hash = Hash.new
    if  ( (@user = User.where(:email => params[:username]).first) &&
          (@streamapi_stream = StreamapiStream.includes(:live_stream_series).where(:public_hostid => params[:public_hostid]).first)
        )
      if (viewer_key_check(@user, @streamapi_stream, params[:viewer_key]))
        @lssp = @user.live_stream_series_permissions.find_by_live_stream_series_id(@streamapi_stream.live_stream_series.id)
        if @lssp
          if @lssp.can_chat && @lssp.can_view
            #let them do both
            options_hash['user'] = @user.full_name
            options_hash['role'] = 'chatter'
            options_hash['code'] = 0
          elsif @lssp.can_view
            #they only get a viewer role
            options_hash['user'] = @user.full_name
            options_hash['role'] = 'viewer'
            options_hash['code'] = 0
          end
        else
          #they are valid mbs users but haven't purchased the stream
          options_hash['code'] = -3
          options_hash['message'] = "You haven't purchased access to this stream.  To do so go #{@streamapi_stream.live_stream_series.purchase_url}"
        end
      else
        # Already logged in with that viewer_key
        options_hash['code'] = -1
        options_hash['message'] = 'You are already viewing this stream. Try closing all stream sessions and trying again after a few minutes.'
      end #/viewer_key_check
    else
      #they didn't pass valid mbs user credentials
      options_hash['code'] = -1
      options_hash['message'] = 'Invalid email and password.'
    end
  
    return options_hash
  end
  
  
  def streamapi_live_stream_finished(params)
    options_hash = Hash.new
    if (@streamapi_stream = StreamapiStream.where(:public_hostid => params[:public_hostid]).first)
      @streamapi_stream.channel_id = params[:channel_id]
      @streamapi_stream.duration = params[:duration].to_i*60 #this one comes in minutes from sapi but we store it in seconds because we get more precision from them later
      @streamapi_stream.total_viewers = params[:viewers].to_i
      @streamapi_stream.max_concurrent_viewers = params[:max_viewers].to_i
      
      if @streamapi_stream.save
        #fixup the options hash
        options_hash['code'] = 0
      else
        options_hash['code'] = -101
      end
    else
      #we couldn't find the record so return failure ot stremaapi
      options_hash['code'] = -100
    end
    return options_hash
  end
  
  
  def streamapi_recording_transcode_finished(params)
    options_hash = Hash.new
    if (@streamapi_stream = StreamapiStream.where(:public_hostid => params[:public_hostid]).first)
      @streamapi_stream.duration = params[:duration] #without a multiplier since this one is straight seconds
      @streamapi_stream.recording_filename = params[:filename]
      @streamapi_stream.recording_url = params[:url]
      
      if @streamapi_stream.save
        options_hash['code'] = 0
      else
        options_hash['code'] = -201
      end
    else
      options_hash['code'] = -100
    end
    return options_hash
  end

  
  def viewer_key_check(user, stream, viewer_key)
    viewer_entry = StreamapiStreamViewerStatus.where(
                      :user_id => user_id,
                      :streamapi_stream_id => stream_id,
                      :viewer_key => viewer_key
                   ).first

    if (viewer_entry.nil? || viewer_entry.count == 0)
      # If there currently is no association between the given user and stream,
      #  then the user is not allowed to view the stream. He hasn't first authenticated with us, or the provided key is fake.
      return false
    end
    logger.info (Time.now - viewer_entry.updated_at) + ' has elapsed.'

    if ( (Time.now - viewer_entry.updated_at) > STREAM_VIEWER_TIMEOUT )
      # If x seconds has elapsed since we last heard from the user, we allow him in.
      # x is defined in environment.rb
      return true
    else
      return false
    end
    
  end

end
