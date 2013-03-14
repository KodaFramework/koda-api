require 'time'

class MongoMedia
  attr_accessor :content_type, :body, :last_updated
  
  def initialize request=nil, params=nil
    if (request != nil)      
      if (request_is_multipart_form(params))
        populate_from_multipart params
      elsif(request_is_octet_stream(params))
        populate_from_octet_stream(params, request)
      else
        populate_from_plain request
     end      
     @last_updated = Time.now.httpdate
    end
  end
  
  private
  
  def populate_from_octet_stream params, request
    @content_type = params[:content_type]
    @body = request.env["rack.input"].read
  end
  
  def populate_from_multipart params
      
    file = params[:file] 
    
    if (file == nil)
      file = params[:files][0]
    end
    
    content_type_header = file[:head].each_line.select {|e| e.include? 'Content-Type'}[0]

    @content_type = content_type_header.split(' ')[1]
    @body = file[:tempfile]
  end
  
  def populate_from_plain request
    @content_type = request.media_type
    @body = request.env["rack.input"].read        
  end
  
  def request_is_multipart_form params
    return false if params == nil    
    params[:files] != nil || params[:file] != nil
  end
  
  def request_is_octet_stream params
    return false if params == nil
    params[:qqfile] != nil
  end
  
end