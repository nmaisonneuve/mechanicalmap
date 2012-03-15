class ApplicationController < ActionController::Base

  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

  #protect_from_forgery

  helper_method :current_or_guest_user

  layout :layout_by_resource


  protected

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        logging_in
        guest_user.destroy
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    User.find(session[:guest_user_id].nil? ? session[:guest_user_id] = create_guest_user.id : session[:guest_user_id])
  end

  private

  def create_guest_user
    u = User.create(:username => "guest_#{Time.now.to_i}#{rand(9)}", :email => "guest_#{Time.now.to_i}#{rand(99)}@email_address.com")
    u.save(:validate => false)
    u
  end

  def anonymous_sign_in
    return if user_signed_in?
    u = User.new()
    temp_token = SecureRandom.base64(15).tr('+/=', 'xyz')
    temp_token="toto"
    u.email="#{temp_token}"
    u.anonymous=true
    u.save(:validate => false)
    sign_in :user, u
  end

end
