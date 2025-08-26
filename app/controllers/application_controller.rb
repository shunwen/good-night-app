class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Skip CSRF verification for JSON API requests
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
end
