module SmegHead
  module ACL

    require 'smeg_head/acl/parser'
    require 'smeg_head/acl/transformer'

    def self.parse(rules)
      PermissionList.parse rules
    end

  end
end
