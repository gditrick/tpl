class League
  attr_accessor     :url,
                    :cost,
                    :fee,
                    :prize_definitions,
                    :number_of_teams

  @@numberOfTeams     = 0
  @@fee               = 0.0
  @@cost              = 0.0
  @@url               = nil
  @@prize_definition  = nil

  def initialize(league, num_of_teams=0)
    @@numberOfTeams        = num_of_teams
    league.number_of_teams = num_of_teams
    @@fee                  = league.fee
    @@cost                 = league.cost
    @@url                  = league.url
    @@prize_definition     = league.prize_definitions.prize_definition(num_of_teams)
  end

  def self.number_of_teams
    @@numberOfTeams
  end

  def self.url
    @@url
  end

  def self.pot
    pot = @@fee * @@numberOfTeams - @@cost
    @@prize_definition.prizes.each do |p|
      next if p.amount.include?("League.pot") unless p.amount.is_a?(Float)
      pot -= (p.eval_amount * p.repeat) if p.is_money?
    end
    return pot
  end

  def self.prize_definition
    return @@prize_definition
  end

  def self.num_of_teams
    return @@numberOfTeams
  end
end
