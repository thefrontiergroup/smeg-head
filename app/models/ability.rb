class Ability
  include CanCan::Ability

  attr_accessor :user, :target

  def initialize(user)
    self.user = user
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Repository Permissions
    can(:create,  Repository) # All users can create repositories
    can(:read,    Repository) # At the moment, all users can read repositories.
    can(:update,  Repository) { |r| owns? r }
    can(:destroy, Repository) { |r| owns? r }

    # SSH Key Permissions
    can(:create,  SshPublicKey)
    can(:read,    SshPublicKey) { |r| owns? r }
    can(:update,  SshPublicKey) { |r| owns? r }
    can(:destroy, SshPublicKey) { |r| owns? r }

    # Permissions on oneself
    can :read,            User
    can :update,          User, :id => user.id
    can :destroy,         User, :id => user.id
    can :manage_ssh_keys, User, :id => user.id

  end


  def owns?(object)
    object.owner_type == 'User' and object.owner_id == user.id
  end

end