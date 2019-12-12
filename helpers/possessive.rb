class String 
  def possessive 
    self + case self[-1,1]
      when 's' then "'" 
      else "'s" 
    end 
  end 
end 
