class ApplicationController < ActionController::Base
  protect_from_forgery


def anonymous_sign_in
  return if user_signed_in?
  u = User.new()
u.anonymous=true
  u.save(:validate => false)
  sign_in :user, u
end

end
