module Gravatarable
  extend ActiveSupport::Concern

  def gravatar_id
    Digest::MD5::hexdigest(email).downcase
  end

  def gravatar_url options=nil
    "//gravatar.com/avatar/#{gravatar_id}.png#{"?" + options.to_query if options.present?}"
  end
end
