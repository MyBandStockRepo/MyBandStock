Rails.application.config.middleware.use OmniAuth::Builder do  
  provider :twitter, "OxTeKBSHEM0ufsguoNNeg", "VFB4ZuSSZ5PDZvhzwjU4NOzh4b1vQHfnBETfYLeOWw"
  provider :facebook, "110251749041497", "158eb74a5eff840f0afb818e378f03aa"
end
