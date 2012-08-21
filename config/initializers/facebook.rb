Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "5927396942", "f77dde57f939b328049d04d663c51e5c",
           :scope => 'email,user_birthday,user_photos,user_location', :display => 'popup',:image_size =>"square"
end