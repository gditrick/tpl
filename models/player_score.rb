class PlayerScore
  attr_accessor :first_name,
                :last_name,
                :position_abbrev,
                :team_abbrev,
                :total

  def initialize
    @total = 0.0
  end

  def full_name
    first_name + ' ' + last_name
  end
end
