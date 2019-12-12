class Winning
  attr_accessor :team,
                :prize,
                :factor,
                :period,
                :score

  def initialize(team=nil, prize=nil, period=nil, score=nil, factor=1)
    @team             = team
    @prize            = prize
    @period           = period
    @score            = score
    @factor           = factor
   
    if @prize.is_a?(CombinedPrize) then 
      @team.winnings_count  += 1.0 unless @team.nil?
      combo_prize = @prize.next_prize
      until combo_prize.nil? do
        @team.winnings_amount += combo_prize.eval_amount if combo_prize.is_money?
        combo_prize = combo_prize.next_prize
      end
      @team.winnings_amount = @team.winnings_amount / @factor
    else
      @team.winnings_count  += 1 unless @team.nil?
      @team.winnings_amount += @prize.eval_amount / @factor if @prize.is_money?
    end
  end
end
