class Winnings < Array
  def find_by_period(period)
    select{|a| a.period == period}
  end

  def select_by_period(period)
    select{|a| a.period == period}
  end

  def find_by_period_and_class(period, klass)
    self.select{|a| a.period == period && a.prize.class.name.eql?(klass)}.first
  end

  def find_by_team(team)
    self.select{|a| a.team == team }
  end
end
