class Teams < Array
  def find_by_name(name=nil)
    return nil if name.nil?
    return nil if self.select{|team| team.name == name}.size != 1
    return self.select{|team| team.name == name}[0] 
  end

  def names
    map(&:name)
  end
end
