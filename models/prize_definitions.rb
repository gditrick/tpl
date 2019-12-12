class PrizeDefinitions < Array
  def prize_definition(num_of_teams)
    self.select{|a| a.team_range.include?(num_of_teams)}.first
  end
end
