class PlayerScores
  attr_accessor :defenses,
                :defensivebacks,
                :defensivelinemen,
                :linebackers,
                :placekickers,
                :quarterbacks,
                :runningbacks,
                :tightends,
                :widereceivers;

  def initialize
    @defenses         = []
    @defensivebacks   = []
    @defensivelinemen = []
    @linebackers      = []
    @placekickers     = []
    @quarterbacks     = []
    @runningbacks     = []
    @tightends        = []
    @widereceivers    = []
  end
end
