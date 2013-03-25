class ApplicationController < ActionController::Base
  protect_from_forgery

  utf8_enforcer_workaround # avoid utf8 parameter in URLs
  
end
