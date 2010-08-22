# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	include Twitter::Autolink


  def lightboard_text(text, options)
  # Returns the raw HTML that displays the given number as lightboard-illuminated text.
  # Options is optional, but should look like
  #  { :digits => 4, :size => 'big' }
    html_string       = ''
    size              = options[:size] || 'small'
    num_digits        = options[:digits] || 3
    text              = bound_number(sprintf("%*s", num_digits, text.to_s).gsub(/ /, '_'))
    lightboard_class  = (size == 'small') ? 'light' : 'biglight'

    text.to_s.each_char{ |char|
      html_string << "<div class=\"#{lightboard_class} l#{char}\"></div>"
    }
    raw html_string
  end


  def pretty_datetime(datetime)
    date = datetime.strftime('%b %e, %Y').downcase
    time = datetime.strftime('%l:%M%p').downcase
    content_tag(:span, date, :class => 'date') + " " + content_tag(:span, time, :class => 'time')
  end
	

	def convert_to_eastern_time(time)
	  return time.utc.in_time_zone('Eastern Time (US & Canada)')
  end
	
	def output_datetime(time)
	  return time.strftime("%a, %B %d, %Y at %I:%M%p %Z")
  end
	
	def bodytag_id
    a = controller.class.to_s.underscore.gsub(/_controller$/, '')
    b = controller.action_name.underscore
    "#{a}-#{b}".gsub(/_/, '-')
  end
  
  
  # Rot13 encodes a string
  def rot13(string)
    string.tr "A-Za-z", "N-ZA-Mn-za-m"
  end


  # HTML encodes ASCII chars a-z, useful for obfuscating
  # an email address from spiders and spammers
  def html_obfuscate(string)
    output_array = []
    lower = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
    upper = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    char_array = string.split('')
    char_array.each do |char|  
      output = lower.index(char) + 97 if lower.include?(char)
      output = upper.index(char) + 65 if upper.include?(char)
      if output
        output_array << "&##{output};"
      else 
        output_array << char
      end
    end
    return output_array.join
  end


  # Takes in an email address and (optionally) anchor text,
  # its purpose is to obfuscate email addresses so spiders and
  # spammers can't harvest them.
  def js_antispam_email_link(email, linktext=email)
    user, domain = email.split('@')
    user   = html_obfuscate(user)
    domain = html_obfuscate(domain)
    # if linktext wasn't specified, throw encoded email address builder into js document.write statement
    linktext = "'+'#{user}'+'@'+'#{domain}'+'" if linktext == email 
    rot13_encoded_email = rot13(email) # obfuscate email address as rot13
    out =  "<noscript>#{linktext}<br/><small>#{user}(at)#{domain}</small></noscript>\n" # js disabled browsers see this
    out += "<script language='javascript'>\n"
    out += "  <!--\n"
    out += "    string = '#{rot13_encoded_email}'.replace(/[a-zA-Z]/g, function(c){ return String.fromCharCode((c <= 'Z' ? 90 : 122) >= (c = c.charCodeAt(0) + 13) ? c : c - 26);});\n"
    out += "    document.write('<a href='+'ma'+'il'+'to:'+ string +'>#{linktext}</a>'); \n"
    out += "  //-->\n"
    out += "</script>\n"
    return out
  end
  
  
  def custom_clean(htmlToClean)
          (htmlToClean || '').gsub(/^\s+/, "").gsub(/\s+$/, $/).gsub(/\r\n|\n|\r/, "").gsub(/["']/) {|m| "\\#{m}"}
  end
  
  
  def make_captcha
    out = ''
    #you have to do a captch random 20% of the time after you get one right
    unless ( (session[:passed_captcha] == true) && (rand(9) <= 8) )
      session[:passed_captcha] = false
      r = 'http://captchator.com/captcha'
      session[:captcha_id] = rand(100000).to_i.to_s
      #f = open("#{r}/image/#{session[:captcha_id]}")
      #out += '<img src="data:image/png;base64,' + Base64.encode64(f.sysread(f.lstat.size)) + '" alt="captcha image" />'
      out += "<img src=\'#{r}/image/#{session[:captcha_id]}\' />"
      out += '<label for="captcha_response">Text from image above</label>'
      out += '<input id="captcha_response" name="captcha_response" type="text" size="10" />'
   end
   return out
  end
  
  
  
private

  
  def bound_number(input, num_digits = 3)
  # Returns input, bounded by ±10^num_digits
  #   Example: b_n(50, 2) -> 50;  b_n(-5000, 3) -> -999
  #
    input = input.to_i
    #see if it's too small      
    if input < ('-'+'9'*(num_digits-1)).to_i # ie. see if -1000 will overflow on a 4 digit setup
      text = '-'+'9'*(num_digits-1)
    #or too big
    elsif input > ('9'*(num_digits)).to_i # ie. see if 1000 will overflow on a 3 digit setup
      text = '9'*(num_digits)
    end
    text.to_i
  end



end

