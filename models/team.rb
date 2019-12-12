class Team
  attr_accessor :id,
                :name,
                :owner,
                :email,
                :winnings_count,
                :winnings_amount


  def initialize(id=1, name, owner, email)
    @id               = id
    @name             = name
    @owner            = owner
    @email            = email
    @winnings_count   = 0
    @winnings_amount  = 0.0
  end

  def owner_first_name
    self.owner.split.first
  end

  def name_and_owner
    self.owner.eql?(self.name) ? self.owner : self.name + "(" + self.owner + ")"
  end
end
