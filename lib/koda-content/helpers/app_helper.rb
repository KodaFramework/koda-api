require 'sinatra'

#
# Application Helpers
#
#  The last line of a method is always the return value
#
#  here you can define any helper methods that are available to your routes and your views
#  
#  -----------------------------------------------------
#  To create a helper method that returns something
#
#  def my_method
#    'something'
#  end
#
#  def my_method(param1, param2)
#     # remember to use doublequotes. single quotes will force a string
#     "using variables in strings #{param1}, #{param2}"
#  end
#  
#  use other helpers
#  
#  def is_user_logged_in?  
#    # there are loads of helpers in /koda/helpers that you could use
#    logged_in?
#  end
#

helpers do
  
  def style_link(path)
    "<link rel=\"StyleSheet\" href=\"#{path}\" type=\"text/css\">"
  end
  
  def script_link(path)
    "<script src=\"#{path}\"></script>"
  end
  
end