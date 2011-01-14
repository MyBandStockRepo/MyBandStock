Factory.sequence :email do |n|
  "user#{n}@example.com"
end
Factory.define :user do |user|
  email = Factory.next :email
  user.first_name         {"Jason"}
  user.email              {email}
  user.email_confirmation {email}
  user.password           {"1234"}
end

Factory.define :admin_user, :parent => :user  do |admin|
  # admin.role_ids {["#{role.id}"]}
end