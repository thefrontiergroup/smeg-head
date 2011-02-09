require 'machinist/active_record'

User.blueprint do
  email                 { Forgery(:internet).email_address }
  login                 { Forgery(:internet).user_name }
  password              { Forgery(:basic).password }
  password_confirmation { object.password }
end

Repository.blueprint do
  name  { Forgery(:name).job_title }
  owner { User.make }
end