task :create_band_secret_tokens => :environment do
  for band in Band.all
    band.secret_token = Digest::MD5.hexdigest(SecureRandom.random_bytes(4))
    puts band.save
  end
end
