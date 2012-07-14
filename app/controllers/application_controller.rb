class ApplicationController < ActionController::Base
  #protect_from_forgery
  helper_method :current_or_guest_username

  protected

  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      current_user
    else
      guest_user
    end
  end

  def current_or_guest_username
    if current_user
      cookies[:guest_user]="" if cookies[:guest_user]
      current_user.username
    else
      guest_username if cookies[:guest_user].blank?
      cookies[:guest_user]
    end
  end

  #use only the cookie to store the current user
  def guest_username
    if (params[:workerId].blank?)
      if cookies[:guest_user].blank?
          o= [(0..9), ('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
          random=(0..6).map { o[rand(o.length)] }.join
          cookies[:guest_user]="guest_#{random}"
      end
    else
          cookies[:guest_user]=params[:workerId]
    end
  end

  # find guest_user
  # creating one if needed
  def guest_user
    guest_username if cookies[:guest_user].blank?
    user=User.find_by_username(cookies[:guest_user])
    if (user.nil?)
      user=create_guest_user(cookies[:guest_user])
    end
    user
  end

  private

  def create_guest_user(username)
    User.new(:username => username, :email => "#{username}@emailguest.com")
  end

end
