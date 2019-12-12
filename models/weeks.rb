class Weeks < AbstractPeriodics
  def find_by_pos(pos=nil)
    return nil if pos.nil?
    return nil if pos < 1 or pos > self.size
    return nil if self[pos-1].pos != pos
    return self[pos-1]
  end

  def current
    self.each do |week|
      return week if week.current?
    end
    return nil
  end
end
