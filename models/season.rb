class Season < AbstractPeriodic
  attr_accessor :halves,
                :quarters,
                :playoffs

  def is_regular_season?
    not @playoffs
  end

  def is_playoffs?
    @playoffs
  end
end
