Rails.application.config.middleware.use OmniAuth::Builder do  
  provider :twitter, "OxTeKBSHEM0ufsguoNNeg", "VFB4ZuSSZ5PDZvhzwjU4NOzh4b1vQHfnBETfYLeOWw"
  provider :facebook, FACEBOOK_APP_ID, FACEBOOK_APP_SECRET
end
