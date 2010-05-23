class ApiController < ApplicationController
  # Required inputs for all API calls:
  #   api_key
  #   hash      - sha256(API key + secret key)
  #   version   - API version number
  # Optional:
  #   output_format    - One of 'xml', 'json', or 'yaml', designating the output_format of the returned values
  #               Defaults to JSON
  #
  # On success, the API functions returns the unmodified API input variables in the output_format specified.
  # On failure, '-1' is returned.
  #

  before_filter :authenticated?, :only => 'test'

  def index
    render :nothing => true
  end

  def change_stream_permission
    # Input: the above input is required; the following are optional:
    #   email, stream_series, can_view, can_chat, quality_level
    # If email is not specified, nothing will happen (but still return success)
    # If email is specified, the specified privileges will be applied to that user.
    # On success, the parameters are sent back in the output_format specified. Also, all
    #   current privileges are also sent back, regardless of whether they were modified.
    # On failure, '-1' is returned.
    #


    stream_quality_level = params[:stream_quality_level]
    stream_series_id = params[:stream_series]
    output_format = params[:output_format] || 'json'
    api_version = params[:api_version]
    can_listen = params[:can_listen].to_i
    can_view = params[:can_view].to_i
    can_chat = params[:can_chat].to_i
    api_key = params[:api_key]
    email = params[:email]
    hash = params[:hash]

    if params[:auto_generate_hash] && Rails.env == 'development' && (api_user = ApiUser.find_by_api_key(api_key))
      hash = Digest::SHA2.hexdigest(api_key.to_s + api_user.secret_key.to_s)
      logger.info "\nAuto-generated hash: #{ hash }\n"
    end
    if (auth(api_key, stream_series_id, hash, api_version) == false)
      logger.info "\nFailed API auth.\n"
      response.headers["Content-Type"] = 'text/html'
      return render :text => '-1'
    end
    logger.info "\nPassed API auth.\n"

    user = User.find_by_email(email.downcase)
    if (user.nil?)
      # User does not exist
      response.headers["Content-Type"] = 'text/html'
      return render :text => '-1'
    end

    privileges_hash = {
                        :can_view => can_view,
                        :can_chat => can_chat,
                        :can_listen => can_listen,
                        :stream_quality_level => stream_quality_level

                      }
    privileges_hash.delete_if { |key, val| val == 'nil' }

    ssp = LiveStreamSeriesPermission.where(:user_id => user.id, :live_stream_series_id => stream_series_id)

    if (ssp.count == 0)
      # User currently has no permissions on the stream
      ssp = LiveStreamSeriesPermission.new(privileges_hash)
      ssp.user_id = user.id
      ssp.live_stream_series_id = stream_series_id
    else
      # User permissions exist and will be changed
      ssp.update(privileges_hash)
    end

    UserMailer.registration_notification(user).deliver

    @output = { :api_key => api_key,
                :hash => hash,
                :api_version => api_version,
                :email => email,
                :can_view => privileges_hash[:can_view] || 0,
                :can_view => privileges_hash[:can_chat] || 0,
                :can_view => privileges_hash[:can_listen] || 0,
                :stream_quality_level => privileges_hash[:stream_quality_level] || 0
              }

#    respond_to do |output_format|
#      output_format.xml { render :xml => @output }
#      output_format.json  { render :json => @output }
#      # output_format.yaml { render :yaml => @output }
#    end
=begin
    if (output_format == 'json')
      render :json => @output
    elsif (output_format == 'xml')
      render :xml => @output
    elsif (output_format == 'yaml')
      # Output YAML from here
    end
=end
    output_format = 'json' if output_format == 'nil'
    logger.info "\nAbout to render callback output.\n"
    case output_format
      when 'json'
        logger.info "\nJSON response\n"
        render :json => @output
      when 'xml'
        render :xml => @output
      when 'yaml'
        #output YAML from here
    end
  end

  def test
  end

private

  def auth(api_key, stream_series_id, input_hash, api_version)
    # Takes API POST input as function parameters, and returns false if the request is unauthorized, true otherwise.

    # Retrun false if:
    #   a parameter is missing
    #   there is no association in the DB between the given api_key and secret_key
    #   there is no association between the ApiUser and the given LiveStreamSeries
    #   the hash wasn't right

    # TODO: check ApiUser-LiveStreamSeries association

    if (api_key.nil? || input_hash.nil? || api_version.nil?)
      return false
    end

    # If the api_key does not exist in DB
    if (! (api_user = ApiUser.find_by_api_key(api_key)) )
      return false
    end

    secret_key = api_user.secret_key
    test_hash = Digest::SHA2.hexdigest(api_key.to_s + secret_key.to_s)
    # If given is not what it is supposed to be; this could either be because
    #  they simply calculated the hash wrong, or did not use the right secret key
    if (input_hash != test_hash.to_s)
      return false
    end

    return true
  end





end
