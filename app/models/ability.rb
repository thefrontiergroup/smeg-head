class Ability
  include CanCan::Ability

  attr_accessor :user, :target

  def initialize(user)
    self.user = user
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Repository Permissions
    can(:create,  Repository) # All users can create repositories
    can(:read,    Repository) # At the moment, all users can read repositories.
    can(:destroy, Repository) { |r| owns? r }
    can(:edit,    Repository) { |r| owns? r }

    # SSH Key Permissions
    can(:create,  SshPublicKey)
    can(:read,    SshPublicKey) { |r| owns? r }
    can(:edit,    SshPublicKey) { |r| owns? r }
    can(:destroy, SshPublicKey) { |r| owns? r }

  end


  def owns?(object)
    object.owner_type == 'User' and object.owner_id == user.id
  end

end
