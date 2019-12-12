class AbstractPrize
  attr_accessor :amount,
                :description,
                :offset,
                :period_type,
                :repeat,
                :next_prize

  def initialize(next_prize=nil)
    @offset     = 0
    @amount     = 0.0
    @repeat     = 1
    @next_prize = next_prize
  end

  def eval_amount
    begin
      return eval(@amount)
    rescue Exception => e
      return @amount
    end
  end

  def amount_to_s
    self.is_money? ? sprintf("$%1.2f", self.eval_amount) : self.eval_amount
  end

  def is_money?
    return false unless self.eval_amount.is_a?(Float)
    true
  end
end
