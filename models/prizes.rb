class Prizes < Array
  @@prideMessage      = "pride that you beat all the other schleps in the league"
  @@tbowlPrideMessage = "pride that you beat all the other schleps in the Toilet Bowl this week"

  def self.pride_message
    @@prideMessage
  end

  def self.tbowl_pride_message
    @@tbowlPrideMessage
  end

  def prize(klass)
    self.select{|a| a.class == klass}.first
  end
end
