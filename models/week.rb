require 'time'

class Week
  attr_accessor :description,
                :first_game_start,
                :half,
                :half_scores,
                :id,
                :last_game_start,
                :lineups_sent_at,
                :next_week,
                :player_scores,
                :pos,
                :previous_week,
                :quarter,
                :quarter_scores,
                :results_sent_at,
                :scores,
                :season,
                :season_scores

  GAME_LENGTH = 4.hours

  def current?
    return false if last_game_start + Week::GAME_LENGTH < Time.now
    return false if previous_week.last_game_start + Week::GAME_LENGTH > Time.now unless self.previous_week.nil?
    true
  end

  def post_scores(teams=nil, scores=nil)
    self.scores = scores.calc_scores!
    self.player_scores = PlayerScores.new
    self.quarter.calc_scores(teams) unless self.quarter.nil?
    self.half.calc_scores(teams) unless self.half.nil?
    self.season.calc_scores(teams)
    self.quarter_scores = QuarterScores.new(self.quarter.scores_at_week(self, teams)) unless self.quarter.nil?
    self.half_scores    = HalfScores.new(self.half.scores_at_week(self, teams)) unless self.half.nil?
    self.season_scores  = SeasonScores.new(self.season.scores_at_week(self, teams))
  end

  def top_player_scores_total
    top_player_scores.inject(0.0){ |m,o| m += o.total.to_f.round(2) }
  end

  def top_player_scores
    [top_quarterback] +
      top_runningbacks +
      top_widereceivers +
      [top_tightend] +
      [top_placekicker] +
      [top_defense]
  end

  def top_quarterback
    player_scores.quarterbacks.sort_by(&:total).reverse.first
  end

  def top_runningbacks
    player_scores.runningbacks.sort_by(&:total).reverse.slice(0..1)
  end

  def top_widereceivers
    player_scores.widereceivers.sort_by(&:total).reverse.slice(0..1)
  end

  def top_tightend
    player_scores.tightends.sort_by(&:total).reverse.first
  end

  def top_placekicker
    player_scores.placekickers.sort_by(&:total).reverse.first
  end

  def top_defense
    player_scores.defenses.sort_by(&:total).reverse.first
  end

  def quarter_top_player_scores_total
    quarter_top_player_scores.inject(0.0){ |m,o| m += o.total.to_f.round(2) }
  end

  def quarter_top_player_scores
    quarter.top_player_scores_for_week(self)
  end

  def half_top_player_scores_total
    half_top_player_scores.inject(0.0){ |m,o| m += o.total.to_f.round(2) }
  end

  def half_top_player_scores
    half.top_player_scores_for_week(self)
  end

  def season_top_player_scores_total
    season_top_player_scores.inject(0.0){ |m,o| m += o.total.to_f.round(2) }
  end

  def season_top_player_scores
    season.top_player_scores_for_week(self)
  end

  def is_end_of_quarter?
    self.quarter.nil? ? false : self.quarter.weeks.last == self
  end

  def is_start_of_quarter?
    self.quarter.nil? ? false : self.quarter.weeks.first == self
  end

  def send_quarter_winner?
    self.is_end_of_quarter? && !self.quarter_scores.empty?
  end

  def is_end_of_half?
    self.half.nil? ? false : self.half.weeks.last == self
  end

  def is_start_of_half?
    self.half.nil? ? false : self.half.weeks.first == self
  end

  def send_half_winner?
    self.is_end_of_half? && !self.half_scores.empty?
  end

  def is_end_of_season?
    self.season.weeks.last == self
  end

  def is_end_of_a_period?
    self.is_end_of_season? || self.is_end_of_half? || self.is_end_of_quarter?
  end

  def is_start_of_a_period?
    self.is_start_of_season? || self.is_start_of_half? || self.is_start_of_quarter?
  end

  def is_start_of_season?
    self.season.weeks.first == self
  end

  def send_season_winner?
    self.is_end_of_season? && !self.season_scores.empty?
  end

  def lineup_reminder_has_been_sent?
    !lineups_sent_at.nil?
  end

  def lineup_reminder_has_not_been_sent?
    !lineup_reminder_has_been_sent?
  end

  def send_lineup_reminder?
    day_to_send = Time.parse(first_game_start.to_s.split(" ")[0]) - 1.day
    day_to_send = Time.parse(first_game_start.to_s.split(" ")[0]) - 2.days if first_game_start.wday == 0
    Time.now >= day_to_send && lineup_reminder_has_not_been_sent?
  end

  def results_have_been_sent?
    !self.results_sent_at.nil?
  end

  def results_have_not_been_sent?
    not self.results_have_been_sent?
  end

  def send_results?
    ResultTxt.file_exists?(self) && self.results_have_not_been_sent? && !self.scores.nil?
  end

  def top_score
    self.top_scores.first
  end

  def top_scores
    self.scores.slice(0..3)
  end

  def top_quarter_score
    self.top_quarter_scores.first
  end

  def top_quarter_scores
    self.quarter_scores.slice(0..3)
  end

  def top_half_score
    self.top_half_scores.first
  end

  def top_half_scores
    self.half_scores.slice(0..3)
  end

  def top_season_score
    self.top_season_scores.first
  end

  def top_season_scores
    self.season_scores.slice(0..3)
  end

  def find_score_by_team(team=nil)
    self.scores.find_by_team(team)
  end
end
