class Score
  attr_accessor :team,
                :period,
                :total,
                :points_behind_1st,
                :points_behind_2nd,
                :points_behind_3rd,
                :points_behind_4th,
                :points_behind_pre,
                :previous_score,
                :next_score

  def initialize(team=nil, period=nil, total=0.0)
    raise "No Team for Score" if team.nil?
    @team              = team
    @period            = period
    @total             = total.to_f.round(2)
    @points_behind_1st = 0.0
    @points_behind_2nd = 0.0
    @points_behind_3rd = 0.0
    @points_behind_4th = 0.0
    @points_behind_pre = 0.0
    @points_behind_pre = 0.0
    @previous_score    = nil
    @next_score        = nil
  end
end
