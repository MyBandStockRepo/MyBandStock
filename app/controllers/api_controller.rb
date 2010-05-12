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
  #

  #before_filter :auth_check

  def change_stream_permission
    # Input: the above input is required; the following are optional:
    #   email, can_view, can_chat, quality_level
    # If email is not specified, nothing will happen (but still return success)
    # If email is specified, the specified privileges will be applied to that user.
    # On success, the parameters are sent back in the output_format specified. Also, all
    #   current privileges are also sent back, regardless of whether they were modified.

    # TODO: output false in the format specified, wherever I wrote 'raise'

    stream_quality_level = params[:stream_quality_level]
    output_format = params[:output_format] || 'json'
    api_version = params[:api_version]
    can_listen = params[:can_listen].to_i
    can_view = params[:can_view].to_i
    can_chat = params[:can_chat].to_i
    api_key = params[:api_key]
    email = params[:email]
    hash = params[:hash]

    if (auth(api_key, hash, api_version) == false)
      raise unauthorized
=begin
      @output = false
      respond_to do |output_format|
        output_format.xml  { render :xml => @output }
        output_format.json  { render :json => @output }
        # output_format.yaml { render :yaml => @output }
      end
      #return
=end
    end

    email_object = UserEmail.find_by_email(email)
    if (email_object.nil?)
      raise user_does_not_exist
    end
    user = email_object.user
    if (user.nil?)
      raise user_does_not_exist
    end

    privileges_hash = { :can_view => can_view,
                        :can_chat => can_chat,
                        :can_listen => can_listen,
                        :stream_quality_level => stream_quality_level
                      }

    user.set_privilege(user, privileges_hash)

    @output = { :api_key => api_key,
                :hash => hash,
                :api_version => api_version,
                :email => email,
                :can_view => can_view,
                :can_view => can_chat,
                :can_view => can_listen,
                :stream_quality_level => stream_quality_level }

#    respond_to do |output_format|
#      output_format.xml { render :xml => @output }
#      output_format.json  { render :json => @output }
#      # output_format.yaml { render :yaml => @output }
#    end
    if (output_format == 'json')
      render :json => @output
    elsif (output_format == 'xml')
      render :xml => @output
    elsif (output_format == 'yaml')
      # Output YAML from here
    end
  end

  def test
    render :layout => 'root-layout'
  end

private

  def auth(api_key, input_hash, api_version)
    # Takes API POST input as function parameters, and returns false if the request is unauthorized, true otherwise.

    # Retrun false if:
    #   a parameter is missing
    #   there is no association in the DB between the given api_key and secret_key
    #   the hash wasn't right

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
