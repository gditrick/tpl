class Integer

  def second
    self
  end
  alias :seconds :second

  def minute
    60.seconds*self
  end
  alias :minutes :minute

  def hour
    60.minutes*self
  end             
  alias :hours :hour

  def day
    24.hours*self
  end
  alias :days :day

  def week
    7.days*self
  end
  alias :weeks :week

  def ago
    Time.now - self
  end
              
end
