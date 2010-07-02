class CallbacksController < ApplicationController
# http://cobain.mybandstock.com/callbacks/streamapi
  respond_to :html, :xml
  skip_before_filter :verify_authenticity_token # Disable CSRF protection for incoming POST requests here
  skip_filter :update_last_location

  def test
  end

  def streamapi
    #get the action from the raw post
    post_arr = request.raw_post.split('&')
    action_str = ""
    Rails.logger.warn "\nRAW - #{post_arr.join(', ') }\n"
    post_arr.each do |one_str|
      if one_str.include?('action=')
        action_str = one_str
      end
    end
    @response_hash = case action_str
      when 'action=login'
        streamapi_authenticate_user(params)
      when 'action=start_live'
        streamapi_live_stream_started(params)
      when 'action=end_live'
        streamapi_live_stream_finished(params)
      when 'action=end_record'
        streamapi_recording_transcode_finished(params)
      else
        Hash.new
    end

    render :xml => @response_hash.to_xml(:root => 'response', :skip_types => true)
  end

  def peekok
    #peekok code will go here
    render :nothing => true
  end

  def myspace
    render :nothing => true
  end


private

  def streamapi_authenticate_user(params)
    options_hash = Hash.new
    viewer_status_entry = StreamapiStreamViewerStatus.where(:viewer_key => params[:key]).first
    if  ( (viewer_status_entry) && (@user = viewer_status_entry.user) &&
          (@streamapi_stream = StreamapiStream.includes(:live_stream_series).where(:public_hostid => params[:public_hostid]).first)
        )
      if (viewer_key_check(@user, @streamapi_stream, params[:key], params[:userip]))
        @lssp = @user.live_stream_series_permissions.find_by_live_stream_series_id(@streamapi_stream.live_stream_series.id)
        if @lssp
          user_name = (@user.full_name.nil? || @user.full_name == '') ? @user.email : @user.full_name
          if (@lssp.can_chat && @lssp.can_view) || @user.can_view_series(@lssp.id)
            #let them do both
            options_hash['user'] = { :name => user_name,
                                     :role => 'chatter' }
            options_hash['code'] = 0
            logger.info "User allowed as a chatter."
          elsif @lssp.can_view
            #they only get a viewer role
            options_hash['user'] = { :name => user_name,
                                     :role => 'viewer' }
            options_hash['code'] = 0
            options_hash['code'] = 0
            logger.info "User allowed as a viewer."
          else
            options_hash['code'] = -3
            options_hash['message'] = "You haven't purchased access to this stream. To do so, visit #{@streamapi_stream.live_stream_series.purchase_url}."
            logger.info 'Reporting code -3, user has a permissions row, but cannot view.'
          end
        else
          #they are valid mbs users but haven't purchased the stream
          options_hash['code'] = -3
          options_hash['message'] = "You haven't purchased access to this stream. To do so, visit #{@streamapi_stream.live_stream_series.purchase_url}."
          logger.info 'Reporting code -3, user has not purchased access.'
        end
      else
        # Already logged in with that viewer_key
        options_hash['code'] = -1
        time_to_go = (STREAM_VIEWER_TIMEOUT - (Time.now - viewer_status_entry.updated_at)).floor
        time_to_go = (time_to_go > 0 && time_to_go < STREAM_VIEWER_TIMEOUT) ? "in #{ time_to_go } seconds" : 'after a few minutes'
        options_hash['message'] = "You are already viewing this stream. Try closing all stream sessions and viewing the stream #{ time_to_go }."
        logger.info 'Reporting code -1, already logged in.'
      end #/viewer_key_check
    else
      #they didn't pass valid mbs user credentials
      options_hash['code'] = -1
      options_hash['message'] = 'Invalid email and password, or stream does not exist.'
      logger.info 'Reporting code -1, stream does not exist.'
    end

    return options_hash
  end

  def streamapi_live_stream_started(params)
    # StreamAPI is telling us there is a new applet broadcasting. If that's the case, there should
    # already be a record in the streamapi_streams table. If not, there's a problem, so we return failure.

    options_hash = Hash.new
    if (@streamapi_stream = StreamapiStream.where(:public_hostid => params[:public_hostid]).first)
      #if @streamapi_stream.save
      #  #fixup the options hash
        options_hash['code'] = 0
      #else
      #  options_hash['code'] = -101
      #end
    else
      #we couldn't find the record so return failure to stremaapi
      options_hash['code'] = -100
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

    if (@recorded_video = RecordedVideo.where(:public_hostid => params[:public_hostid]).first)
      if params[:duration] && params[:duration] > 0
        @recorded_video.url = params[:url]
        @recorded_video.duration = params[:duration]
        if @recorded_video.save
          options_hash['code'] = 0
        else
          options_hash['code'] = -201
        end
      else
        options_hash['code'] = -100
      end
    else
      options_hash['code'] = -100
    end


=begin
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
=end
    return options_hash

  end


  def viewer_key_check(user, stream, viewer_key, user_ip)
    viewer_entry = StreamapiStreamViewerStatus.where(
                      :user_id => user.id,
                      :streamapi_stream_id => stream.id,
                      :viewer_key => viewer_key
                   ).first

    if (viewer_entry.nil?)
      # If there currently is no association between the given user and stream,
      #  then the user is not allowed to view the stream. He hasn't first authenticated with us, or the provided key is fake.
      logger.info "Viewer key check: key does not exist. [#{ viewer_key }]"
      return false
    end
    logger.info 'Viewer key check: ' + (Time.now - viewer_entry.updated_at).to_s + ' seconds have elapsed since last update.'

    if ( (Time.now - viewer_entry.updated_at) > STREAM_VIEWER_TIMEOUT)
      # If x seconds has elapsed since we last heard from the user, we allow him in.
      # x is defined in environment.rb
      viewer_entry.ip_address = user_ip # Stash the user's IP
      viewer_entry.save
      logger.info 'Time limit exceeded, so we allow user to view.'
      return true
    else
      if (viewer_entry.ip_address != nil)
        # If < time limit AND this user has not pinged us yet (his key was generated, but we do not have an IP for him).
        logger.info "We are still within the time limit (#{ STREAM_VIEWER_TIMEOUT } seconds), so deny user."
        return false
      end
    end

    return true
  end

end
