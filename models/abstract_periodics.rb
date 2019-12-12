class AbstractPeriodics < Array
  def current(week=nil)
    self.each do |periodic|
      case periodic
        when Quarter then return periodic if periodic == week.quarter
        when Half then return periodic if periodic == week.half
        when Season then return periodic if periodic == week.season
      end
    end unless week.nil?
    return nil
  end

  def previous
    previous_periodic = nil
    self.each do |periodic|
      return previous_periodic if periodic == self.current
      previous_periodic = periodic
    end
    return previous_periodic
  end

  def scores_by_team(team)
    scores = Scores.new
    self.each do |period|
      scores.concat(period.scores.select{ |a| a.team == team }) unless period.scores.nil? or period.scores.empty?
    end
    return Scores.new(scores.sort_by{ |a| -a.total.to_f.round(2) })
  end

  def all_scores
    scores = Scores.new
    self.each do |period|
      scores.concat(period.scores) unless period.scores.nil? or period.scores.empty?
    end
    return Scores.new(scores.sort_by{ |a| [-a.total.to_f.round(2), a.team.name] })
  end
end
