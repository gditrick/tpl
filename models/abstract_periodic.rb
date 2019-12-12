class AbstractPeriodic
  attr_accessor :description,
                :id,
                :pos,
                :scores,
                :season,
                :weeks

  def calc_scores(teams=nil)
    scores = Scores.new
    teams.each do |team|
      score = Score.new(team=team, period=self)
      self.weeks.each do |week|
        total = score.total.to_f.round(2)
        total += week.scores.find_by_team(team).total.to_f.round(2) unless week.scores.nil?
        score.total = total.to_f.round(2)
      end
      scores << score
    end
    self.scores = Scores.new(scores.sort_by{|a| [-a.total, a.team.name]})
    self.scores.calc_scores!
  end

  def scores_at_week(at_week=nil, teams=nil)
    scores = Scores.new    
    teams.each do |team|
      score = Score.new(team=team, period=self)
      self.weeks.each do |week|
        total = score.total.to_f.round(2)
        total += week.scores.find_by_team(team).total.to_f.round(2) unless week.scores.nil?
        score.total = total.to_f.round(2)
        break if week == at_week
      end
      scores << score
    end
    return Scores.new(scores.sort_by{|a| [-a.total, a.team.name]}).calc_scores!
  end

  def week_of_score(score=nil)
    return nil if score.nil?
    self.weeks.each do |week|
      return week if week.scores.include?(score)
    end
    return nil
  end

  def weekly_scores(to_week=nil)
    weekly_scores = Scores.new
    self.weeks.each do |week|
      weekly_scores += week.scores unless week.scores.nil?
      break if week == to_week unless to_week.nil?
    end

    return Scores.new(weekly_scores.sort_by{|a| [-a.total, a.team.name]})
  end

  def highest_weekly(to_week=nil)
    self.weekly_scores(to_week).first
  end

  def top_weekly_scores(to_week=nil)
    self.weekly_scores(to_week).slice(0..4)
  end

  def top_player_scores_for_week(week)
    top_players   = []
    quarterbacks  = []
    runningbacks  = []
    widereceivers = []
    tightends     = []
    placekickers  = []
    defenses      = []
    weeks.each do |w|
      if w == week
        remaining_qbs = w.player_scores.quarterbacks.sort_by(&:total).reverse.reject do |qb|
          quarterbacks.map(&:team_abbrev).include?(qb.team_abbrev) &&
            quarterbacks.map(&:last_name).include?(qb.last_name)
        end

        top_players << remaining_qbs.first

        remaining_rbs = w.player_scores.runningbacks.sort_by(&:total).reverse.reject do |rb|
          runningbacks.map(&:team_abbrev).include?(rb.team_abbrev) &&
            runningbacks.map(&:last_name).include?(rb.last_name)
        end

        top_players |= remaining_rbs.slice(0..1)

        remaining_rbs = w.player_scores.runningbacks.sort_by(&:total).reverse.reject do |rb|
          runningbacks.map(&:team_abbrev).include?(rb.team_abbrev) &&
            runningbacks.map(&:last_name).include?(rb.last_name)
        end

        top_players |= remaining_rbs.slice(0..1)

        remaining_wrs = w.player_scores.widereceivers.sort_by(&:total).reverse.reject do |wr|
          widereceivers.map(&:team_abbrev).include?(wr.team_abbrev) &&
            widereceivers.map(&:last_name).include?(wr.last_name)
        end

        top_players |= remaining_wrs.slice(0..1)

        remaining_tes = w.player_scores.tightends.sort_by(&:total).reverse.reject do |te|
          tightends.map(&:team_abbrev).include?(te.team_abbrev) &&
            tightends.map(&:last_name).include?(te.last_name)
        end

        top_players << remaining_tes.first

        remaining_pks = w.player_scores.placekickers.sort_by(&:total).reverse.reject do |pk|
          placekickers.map(&:team_abbrev).include?(pk.team_abbrev) &&
            placekickers.map(&:last_name).include?(pk.last_name)
        end

        top_players << remaining_pks.first

        remaining_dfs = w.player_scores.defenses.sort_by(&:total).reverse.reject do |df|
          defenses.map(&:team_abbrev).include?(df.team_abbrev) &&
            defenses.map(&:last_name).include?(df.last_name)
        end

        top_players << remaining_dfs.first

        break
      else
        quarterbacks  << w.top_quarterback
        runningbacks  |= w.top_runningbacks
        widereceivers |= w.top_widereceivers
        tightends     << w.top_tightend
        placekickers  << w.top_placekicker
        defenses      << w.top_defense
      end
    end
    top_players
  end
end
