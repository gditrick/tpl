class PrizeDefinition
  attr_accessor :team_range,
                :prizes

  def prize(klass)
    self.prizes.select{|a| a.class == klass}.first
  end
end
