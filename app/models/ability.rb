class Ability
  include CanCan::Ability

  attr_accessor :user, :target

  def initialize(user)
    self.user = user
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Repository Permissions
    can(:create,  Repository) # All users can create repositories
    can(:update,  Repository) { |r| r.administrator? user }
    can(:destroy, Repository) { |r| r.administrator? user }
    can(:read,    Repository) { |r| r.publically_accessible? or r.member?(user) }

    # SSH Key Permissions
    can(:create,  SshPublicKey)
    can(:read,    SshPublicKey) { |r| owns? r }
    can(:update,  SshPublicKey) { |r| owns? r }
    can(:destroy, SshPublicKey) { |r| owns? r }
    
    # Collaboration Permissions
    can(:create,  Collaboration)
    can(:read,    Collaboration) { |c| c.user == user or owns? c.repository }
    can(:update,  Collaboration) { |c| owns? c.repository }
    can(:destroy, Collaboration) { |c| c.user == user or owns? c.repository }

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
