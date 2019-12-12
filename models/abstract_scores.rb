class AbstractScores < Array
  def find_by_team(team=nil)
    return nil if team.nil?
    return nil if self.select{|a| a.team == team}.size != 1
    return self.select{|a| a.team == team}.first
  end

  def find_by_total(total=nil)
    return nil if total.nil?
    return self.select{|a| a.total.to_f.round(2) == total.to_f.round(2)}
  end

  def average
    average = 0.0
    self.reject{|a| a.total.to_f.round(2) == 0.0}.map(&:total).each do |total|
      average += total
    end
    (average / self.reject{|a| a.total.to_f.round(2) == 0.0}.size).round(3)
  end

  def lowest
    self.reject{|a| a.total.to_f.round(2) == 0.0}.last
  end

  def calc_scores!
    self.each_with_index do |score, idx|
      score.points_behind_1st = (self.first.total - score.total).round(2) unless self.size < 1
      score.points_behind_2nd = (self[1].total - score.total).round(2) unless self.size < 2 or idx < 1
      score.points_behind_3rd = (self[2].total - score.total).round(2) unless self.size < 3 or idx < 2
      score.points_behind_4th = (self[3].total - score.total).round(2) unless self.size < 4 or idx < 3
      score.points_behind_pre = (self[idx-1].total - score.total).round(2) unless idx < 1
      score.previous_score    = self[idx-1] unless idx == 0
      score.next_score        = self[idx+1] unless idx >= self.size - 1
    end
  end

  def rank_by_score(score)
    self.each_with_index do |s,idx|
      if s == score then
        return idx+1
      end
    end
    0
  end

  def rank_by_team(team)
    self.each_with_index do |s,idx|
      if s.team == team then
        return idx+1
      end
    end
    0
  end
end
