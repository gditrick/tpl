class TeamNameMapping
  attr_accessor :from_name,
                :to_name

  def initialize(from, to)
    @from_name = from
    @to_name   = to
  end
end
