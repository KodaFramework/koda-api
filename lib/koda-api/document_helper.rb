module Koda
  module DocumentHelper
    def get_or_create_document(uri)
      existing_document = Koda::Document.where(uri: uri).first
      is_new = existing_document.nil?
      existing_document = Koda::Document.for(uri) if is_new
      {
        document: existing_document,
        is_new: is_new
      }
    end

    def uri
      request.path_info.gsub request.script_name, ''
    end
  end
end