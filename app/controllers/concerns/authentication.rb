module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

    def require_authentication
      Current.user = User.find_by(id: cookies.signed[:user_id].to_i)
      head :unauthorized unless Current.user
    end
end
