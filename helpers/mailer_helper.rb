module MailerHelper
  def add_change_col?(week, scores)
    return false if week.previous_week.nil?
    return false if scores.is_a?(Scores)
    return false if week.is_start_of_quarter? and scores.is_a?(QuarterScores)
    return false if week.is_start_of_half? and scores.is_a?(HalfScores)
    return false if week.is_start_of_season? and scores.is_a?(SeasonScores)
    true
  end

  def delta(week, scores, team)
    case scores
      when Scores then
         return week.previous_week.scores.index(week.previous_week.scores.find_by_team(team)) - week.scores.index(week.scores.find_by_team(team)) 
      when QuarterScores then
         return week.previous_week.quarter_scores.index(week.previous_week.quarter_scores.find_by_team(team)) - week.quarter_scores.index(week.quarter_scores.find_by_team(team)) 
      when HalfScores then
         return week.previous_week.half_scores.index(week.previous_week.half_scores.find_by_team(team)) - week.half_scores.index(week.half_scores.find_by_team(team)) 
      when SeasonScores then
         return week.previous_week.season_scores.index(week.previous_week.season_scores.find_by_team(team)) - week.season_scores.index(week.season_scores.find_by_team(team)) 
      else
        return 0
    end
  end

  def change_col_header_html(week, scores)
    if add_change_col?(week, scores)
      content_tag(:th, 'Change', style: th_default, rowspan: "2")
    end
  end

  def change_col_detail_html(week, scores, team, html_style)
    if add_change_col?(week, scores)
      change = delta(week, scores, team)
      if change < 0
        content_tag(:td, "-" + change.abs.to_s, style: td_default + td_highlight_bad + td_ordinal)
      elsif change > 0
        content_tag(:td, "+" + change.abs.to_s, style: td_default + td_highlight_good + td_ordinal)
      else
        content_tag(:td, "--", style: td_default + html_style + td_ordinal)
      end
    end
  end

  def header_line1_plain(week, scores)
    plain=""
    if add_change_col?(week, scores)
      plain << sprintf("%84.84s", '-' * 84)
    else
      plain << sprintf("%76.76s", '-' * 76)
    end
    plain
  end

  alias header_line4_plain header_line1_plain
  alias footer_line1_plain header_line1_plain

  def header_line2_plain(week, scores)
    plain=""
    if add_change_col?(week, scores)
      plain << sprintf("%5.5s|%22.22s|%6.6s|%7.7s|%40.40s",
                       "", "", "","", "Points Behind           ")
    else
      plain << sprintf("%5.5s|%22.22s|%7.7s|%40.40s",
                       "", "", "", "Points Behind           ")
    end
    plain
  end

  def header_line3_plain(week, scores)
    plain=""
    if add_change_col?(week, scores)
      plain << sprintf("%5.5s|%22.22s|%6.6s|%7.7s|%7.7s %7.7s %7.7s %7.7s %7.7s",
                       "Place",
                       "Team        ",
                       "Change",
                       "Score ",
                       "Prev  ",
                       "#{1.en.ordinal}  ",
                       "#{2.en.ordinal}  ",
                       "#{3.en.ordinal}  ",
                       "#{4.en.ordinal}  "
               )
    else
      plain << sprintf("%5.5s|%22.22s|%7.7s|%7.7s %7.7s %7.7s %7.7s %7.7s",
                       "Place",
                       "Team        ",
                       "Score ",
                       "Prev  ",
                       "#{1.en.ordinal}  ",
                       "#{2.en.ordinal}  ",
                       "#{3.en.ordinal}  ",
                       "#{4.en.ordinal}  "
               )
    end
    plain
  end

  def detail_line1_plain(score, place, week, scores, team)
    plain=""
    if add_change_col?(week, scores)
      change   = delta(week, scores, team)
      change_s = ""
      if change < 0
        change_s << "-" + "#{change.abs}"
      elsif change > 0
        change_s << "+" + "#{change.abs}"
      else
        change_s << '--'
      end
      plain << sprintf("%-5.5s %-22.22s %6.6s %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f",
                       place.en.ordinal,
                       score.team.name,
                       change_s.concat(" " * (3 - change_s.length/2)),
                       score.total,
                       score.points_behind_pre,
                       score.points_behind_1st,
                       score.points_behind_2nd,
                       score.points_behind_3rd,
                       score.points_behind_4th
               )
    else
      plain << sprintf("%-5.5s %-22.22s %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f",
                       place.en.ordinal,
                       score.team.name,
                       score.total,
                       score.points_behind_pre,
                       score.points_behind_1st,
                       score.points_behind_2nd,
                       score.points_behind_3rd,
                       score.points_behind_4th
               )
    end
  end

  def score_ranking_hdr_row1_html(periodics)
    html='<tr style="' + tr_default + '">'
    case periodics
      when Weeks then
        html << '<th rowspan="2" style="' + th_default + '">' + periodics.class.name.singularize + '</th>'
        html << '<th rowspan="2" style="' + th_default + '">Score</th>'
        html << '<th colspan="3" style="' + th_default + '">Ranking</th>'
        html << '<th colspan="4" style="' + th_default + '">League Ranking</th>'
        html << '<th rowspan="2" style="' + th_default + '">Average</th>'
        html << '<th rowspan="2" style="' + th_default + '">Highest</th>'
        html << '<th rowspan="2" style="' + th_default + '">Lowest</th>'
      when Quarters then
        html << '<th rowspan="2" style="' + th_default + '">' + periodics.class.name.singularize + '</th>'
        html << '<th rowspan="2" style="' + th_default + '">Score</th>'
        html << '<th colspan="2" style="' + th_default + '">Ranking</th>'
        html << '<th colspan="3" style="' + th_default + '">League Ranking</th>'
        html << '<th rowspan="2" style="' + th_default + '">Average</th>'
        html << '<th rowspan="2" style="' + th_default + '">Highest</th>'
        html << '<th rowspan="2" style="' + th_default + '">Lowest</th>'
      when Halves then
        html << '<th rowspan="2" style="' + th_default + '">' + periodics.class.name.singularize + '</th>'
        html << '<th rowspan="2" style="' + th_default + '">Score</th>'
        html << '<th rowspan="2" style="' + th_default + '">Ranking</th>'
        html << '<th colspan="2" style="' + th_default + '">League Ranking</th>'
        html << '<th rowspan="2" style="' + th_default + '">Average</th>'
        html << '<th rowspan="2" style="' + th_default + '">Highest</th>'
        html << '<th rowspan="2" style="' + th_default + '">Lowest</th>'
    end
    html << '</tr>'
  end

  def score_ranking_hdr_row2_html(periodics)
    html=""
    case periodics
      when Weeks then
        html << '<tr style="' + tr_default + '">'
        html << '<th style="' + th_default + '">Season</th>'
        html << '<th style="' + th_default + '">Half</th>'
        html << '<th style="' + th_default + '">Quarter</th>'
        html << '<th style="' + th_default + '">Season</th>'
        html << '<th style="' + th_default + '">Half</th>'
        html << '<th style="' + th_default + '">Quarter</th>'
        html << '<th style="' + th_default + '">Week</th>'
        html << '</tr>'
      when Quarters then
        html << '<tr style="' + tr_default + '">'
        html << '<th style="' + th_default + '">Season</th>'
        html << '<th style="' + th_default + '">Half</th>'
        html << '<th style="' + th_default + '">Season</th>'
        html << '<th style="' + th_default + '">Half</th>'
        html << '<th style="' + th_default + '">Quarter</th>'
        html << '</tr>'
      when Halves then
        html << '<tr style="' + tr_default + '">'
        html << '<th style="' + th_default + '">Season</th>'
        html << '<th style="' + th_default + '">Half</th>'
        html << '</tr>'
    end
    html
  end

  def score_ranking_col_detail_html(score, team, td_style)
    html=""
    case score.period
      when Week then
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.season.weeks.scores_by_team(team).rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.half.weeks.scores_by_team(team).rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.quarter.weeks.scores_by_team(team).rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.season.weeks.all_scores.rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.half.weeks.all_scores.rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.quarter.weeks.all_scores.rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.scores.rank_by_score(score).en.ordinal + '</td>'
      when Quarter then
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.season.quarters.scores_by_team(team).rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.half.quarters.scores_by_team(team).rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.season.quarters.all_scores.rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.half.quarters.all_scores.rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.scores.rank_by_score(score).en.ordinal + '</td>'
      when Half then
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.season.halves.scores_by_team(team).rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.season.halves.all_scores.rank_by_score(score).en.ordinal + '</td>'
        html << '<td style="' + td_default + td_style + td_ordinal + '">' + score.period.scores.rank_by_score(score).en.ordinal + '</td>'
    end
    html
  end

  def progression_col_detail_html(week, team, td_style)
    html=""

    week_change = 0 
    unless week.previous_week.nil?
      week_change = delta(week, week.scores, team)
    end

    quarter_change = 0 
    unless week.is_start_of_quarter?
      quarter_change = delta(week, week.quarter_scores, team)
    end

    half_change = 0 
    unless week.is_start_of_half?
      half_change = delta(week, week.half_scores, team)
    end

    season_change = 0 
    unless week.is_start_of_season?
      season_change = delta(week, week.season_scores, team)
    end

    if week_change < 0
      html << '<td style="' + td_grouping + td_highlight_bad + td_ordinal + '">'
    elsif week_change > 0
      html << '<td style="' + td_grouping + td_highlight_good + td_ordinal + '">'
    else
      html << '<td style="' + td_grouping + td_style + td_ordinal + '">'
    end
    html << week.scores.rank_by_team(team).en.ordinal
    html << '</td>'

    if quarter_change < 0
      html << '<td style="' + td_grouping + td_highlight_bad + td_ordinal + '">'
    elsif quarter_change > 0
      html << '<td style="' + td_grouping + td_highlight_good + td_ordinal + '">'
    else
      html << '<td style="' + td_grouping + td_style + td_ordinal + '">'
    end
    html << week.quarter_scores.rank_by_team(team).en.ordinal
    html << '</td>'

    if half_change < 0
      html << '<td style="' + td_grouping + td_highlight_bad + td_ordinal + '">'
    elsif half_change > 0
      html << '<td style="' + td_grouping + td_highlight_good + td_ordinal + '">'
    else
      html << '<td style="' + td_grouping + td_style + td_ordinal + '">'
    end
    html << week.half_scores.rank_by_team(team).en.ordinal
    html << '</td>'

    if season_change < 0
      html << '<td style="' + td_grouping + td_highlight_bad + td_ordinal + '">'
    elsif season_change > 0
      html << '<td style="' + td_grouping + td_highlight_good + td_ordinal + '">'
    else
      html << '<td style="' + td_grouping + td_style + td_ordinal + '">'
    end
    html << week.season_scores.rank_by_team(team).en.ordinal
    html << '</td>'

    html
  end

  def league_week_col_detail_html(period, team, scores, style)
    html     = ""
    td_style = td_large + style

    html << '<td style="' + td_style + '">' + period.description + "</td>"
    html << '<td style="' + td_style + td_number + '">' + sprintf("%1.3f", scores.average) + "</td>"
    if scores.first.team == team then
      html << '<td style="' + td_style + td_highlight_good + '">'
      html << scores.first.team.name_and_owner + '</td>'
      html << '<td style="' + td_style + td_highlight_good + td_number + '">'
      html << sprintf("%1.2f", scores.first.total) + '</td>'
    else
      html << '<td style="' + td_style + '">' + scores.first.team.name_and_owner + "</td>"
      html << '<td style="' + td_style + td_number + '">' + sprintf("%1.2f", scores.first.total) + '</td>'
    end
    if scores.lowest.team == team then
      html << '<td style="' + td_style + td_highlight_bad + '">'
      html << scores.lowest.team.name_and_owner + '</td>'
      html << '<td style="' + td_style + td_highlight_bad + td_number + '">'
      html << sprintf("%1.2f", scores.lowest.total) + '</td>'
    else
      html << '<td style="' + td_style + '">' + scores.lowest.team.name_and_owner + "</td>"
      html << '<td style="' + td_style + td_number + '">' + sprintf("%1.2f", scores.lowest.total) + '</td>'
    end
#
#   html << '<td style="' + td_style + td_number + '">' + sprintf("%1.3f", week.quarter_scores.average) + "</td>"
#   if week.quarter_scores.first.team == team then
#     html << '<td style="' + td_style + td_highlight_good + '">'
#     html << week.quarter_scores.first.team.name_and_owner + '</td>'
#     html << '<td style="' + td_style + td_highlight_good + td_number + '">'
#     html << sprintf("%1.2f", week.quarter_scores.first.total) + '</td>'
#   else
#     html << '<td style="' + td_style + '">' + week.quarter_scores.first.team.name_and_owner + "</td>"
#     html << '<td style="' + td_style + td_number + '">' + sprintf("%1.2f", week.quarter_scores.first.total) + '</td>'
#   end
#   if week.quarter_scores.lowest.team == team then
#     html << '<td style="' + td_style + td_highlight_bad + '">'
#     html << week.quarter_scores.lowest.team.name_and_owner + '</td>'
#     html << '<td style="' + td_style + td_highlight_bad + td_number + '">'
#     html << sprintf("%1.2f", week.quarter_scores.lowest.total) + '</td>'
#   else
#     html << '<td style="' + td_style + '">' + week.quarter_scores.lowest.team.name_and_owner + "</td>"
#     html << '<td style="' + td_style + td_number + '">' + sprintf("%1.2f", week.quarter_scores.lowest.total) + '</td>'
#   end
#
#   html << '<td style="' + td_style + td_number + '">' + sprintf("%1.3f", week.half_scores.average) + "</td>"
#   if week.half_scores.first.team == team then
#     html << '<td style="' + td_style + td_highlight_good + '">'
#     html << week.half_scores.first.team.name_and_owner + '</td>'
#     html << '<td style="' + td_style + td_highlight_good + td_number + '">'
#     html << sprintf("%1.2f", week.half_scores.first.total) + '</td>'
#   else
#     html << '<td style="' + td_style + '">' + week.half_scores.first.team.name_and_owner + "</td>"
#     html << '<td style="' + td_style + td_number + '">' + sprintf("%1.2f", week.half_scores.first.total) + '</td>'
#   end
#   if week.half_scores.lowest.team == team then
#     html << '<td style="' + td_style + td_highlight_bad + '">'
#     html << week.half_scores.lowest.team.name_and_owner + '</td>'
#     html << '<td style="' + td_style + td_highlight_bad + td_number + '">'
#     html << sprintf("%1.2f", week.half_scores.lowest.total) + '</td>'
#   else
#     html << '<td style="' + td_style + '">' + week.half_scores.lowest.team.name_and_owner + "</td>"
#     html << '<td style="' + td_style + td_number + '">' + sprintf("%1.2f", week.half_scores.lowest.total) + '</td>'
#   end
#
#   html << '<td style="' + td_style + td_number + '">' + sprintf("%1.3f", week.season_scores.average) + "</td>"
#   if week.season_scores.first.team == team then
#     html << '<td style="' + td_style + td_highlight_good + '">'
#     html << week.season_scores.first.team.name_and_owner + '</td>'
#     html << '<td style="' + td_style + td_highlight_good + td_number + '">'
#     html << sprintf("%1.2f", week.season_scores.first.total) + '</td>'
#   else
#     html << '<td style="' + td_style + '">' + week.season_scores.first.team.name_and_owner + "</td>"
#     html << '<td style="' + td_style + td_number + '">' + sprintf("%1.2f", week.season_scores.first.total) + '</td>'
#   end
#   if week.season_scores.lowest.team == team then
#     html << '<td style="' + td_style + td_highlight_bad + '">'
#     html << week.season_scores.lowest.team.name_and_owner + '</td>'
#     html << '<td style="' + td_style + td_highlight_bad + td_number + '">'
#     html << sprintf("%1.2f", week.season_scores.lowest.total) + '</td>'
#   else
#     html << '<td style="' + td_style + '">' + week.season_scores.lowest.team.name_and_owner + "</td>"
#     html << '<td style="' + td_style + td_number + '">' + sprintf("%1.2f", week.season_scores.lowest.total) + '</td>'
#   end
#
    html
  end

  def league_winnings_total_col_detail_html(winnings)
    total = 0.0
    winnings.each do |winning|
      if winning.prize.is_money?
        total += winning.prize.eval_amount
      end
    end
    '<th style="' + th_default + th_totalamount + '">' + sprintf("$%1.2f", total) + "</td>"
  end

  WHITE     = "#FFFFFF"

  GAINSBORO        = "#DCDCDC"
  LIGHTGRAY        = "#D3D3D3"
  SILVER           = "#C0C0C0"
  DARKGRAY         = "#A9A9A9"
  GRAY             = "#808080"
  DIMGRAY          = "#696969"
  LIGHTSLATEGRAY   = "#778899"
  SLATEGRAY        = "#708090"
  DARKSLATEGRAY    = "#2F4F4F"
  BLACK            = "#000000"

  LIME = "#00FF00"

  RED = "#FF0000"

  YELLOW = "#FFFF00"

  def style_bg_color(color_code=nil)
    color_code.nil? ? "background-color:" + WHITE + ";" :  "background-color:" + color_code + ";"
  end

  def style_color(color_code=nil)
    color_code.nil? ? "color:" + BLACK + ";" :  "color:" + color_code + ";"
  end

  def style_text_align(alignment=nil)
    alignment.nil? ? "text-align:left;" : "text-align:" + alignment + ";"
  end

  def style_padding(top=nil, right=nil, bottom=nil, left=nil)
    if top.nil? and right.nil? and bottom.nil? and left=nil?
      return "padding: 0px;"
    end

    style  = "padding:"
    style += " " + top.to_s    + "px" unless top.nil?
    style += " " + right.to_s  + "px" unless right.nil?
    style += " " + bottom.to_s + "px" unless bottom.nil?
    style += " " + left.to_s   + "px" unless left.nil?

    style += ";"
  end

  def style_border_color(color_code=nil)
    color_code.nil? ? "border-color:" + BLACK + ";" :  "border-color:" + color_code + ";"
  end

  def style_border_width(top=nil, right=nil, bottom=nil, left=nil)
    if top.nil? and right.nil? and bottom.nil? and left=nil?
      return "border-width: 2px;"
    end

    style  = "border-width:"
    style += " " + top.to_s    + "px" unless top.nil?
    style += " " + right.to_s  + "px" unless right.nil?
    style += " " + bottom.to_s + "px" unless bottom.nil?
    style += " " + left.to_s   + "px" unless left.nil?

    style += ";"
  end

  def style_border_style(top=nil, right=nil, bottom=nil, left=nil)
    if top.nil? and right.nil? and bottom.nil? and left=nil?
      return "border-style: solid;"
    end

    style  = "border-style:"
    style += " " + top unless top.nil?
    style += " " + right unless right.nil?
    style += " " + bottom unless bottom.nil?
    style += " " + left unless left.nil?

    style += ";"
  end

  def style_border_collapse(value=nil)
    value.nil? ? "border-collapse:collapse" : "border-collapse:" + value + ";"
  end

  def style_font(font_style=nil, font_weight=nil, font_size=nil, font_family=nil)
    style  = "font:" unless font_style.nil? and font_weight.nil? and font_size.nil? and font_family.nil?
    style += " " + font_style unless font_style.nil?
    style += " " + font_weight unless font_weight.nil?
    style += " " + font_size unless font_size.nil?
    style += " " + font_family unless font_family.nil?

    style += ";" unless font_style.nil? and font_weight.nil? and font_size.nil? and font_family.nil?
  end

  def div_table_default
    'display: table;'
  end

  def div_table_caption_default
    'display: table-caption; text-align: center; font-weight: bold; font-size: larger;'
  end

  def div_table_row_default
    'display: table-row;'
  end

  def div_table_cell_default
    'display: table-cell; border: solid; border-width: thin; padding-left: 5px; padding-right: 5px;'
  end

  def div_table_middle_cell_default
    div_table_cell_default + 'width: 40px;'
  end

  def table_default
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_border_collapse("collapse") +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_text_align("left")
  end

  def table_grouping
    style_border_width(4) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_border_collapse("collapse") +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_text_align("left")
  end

  def table_large
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_border_collapse("collapse") +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_font("normal","normal","0.750em","Georgia,serif") +
    style_text_align("left")
  end

  def caption_default
    style_bg_color(DARKSLATEGRAY) +
    style_color(WHITE) +
    style_font("italic","800","1.25em","Georgia,serif") +
    style_text_align("center")
  end

  def caption_large
    style_bg_color(DARKSLATEGRAY) +
    style_color(WHITE) +
    style_font("italic","800","1.667em","Georgia,serif") +
    style_text_align("center")
  end

  def thead_grouping
    style_border_width(4) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_text_align("center")
  end

  def thead_large
    style_border_width(4) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_font("normal","bold","1.000em","Georgia,serif") +
    style_text_align("center")
  end

  def tbody_grouping
    style_border_width(4) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_text_align("left")
  end

  def tbody_large
    style_border_width(4) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_font("normal","normal","1.000em","Georgia,serif") +
    style_text_align("left")
  end
  def tbody_grouping_even
    style_bg_color(GAINSBORO)
  end

  def tbody_grouping_odd
    style_bg_color(DARKGRAY)
  end

  def tfoot_grouping
    style_border_width(4) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_text_align("center")
  end

  def tfoot_large
    style_border_width(4) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_font("normal","bold","1.000em","Georgia,serif") +
    style_text_align("center")
  end

  def tr_default
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_text_align("left")
  end

  def tr_grouping
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_text_align("left")
  end

  def tr_large
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_font("normal","normal","1.000em","Georgia,serif") +
    style_text_align("left")
  end

  def tr_even
    style_bg_color(GAINSBORO)
  end

  def tr_grouping_even
    style_bg_color(GAINSBORO)
  end

  def tr_odd
    style_bg_color(DARKGRAY)
  end

  def tr_grouping_odd
    style_bg_color(DARKGRAY)
  end

  def tr_team
    style_bg_color(YELLOW)
  end

  def th_default
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(GRAY) +
    style_color(BLACK) +
    style_text_align("center")
  end

  def th_grouping
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(GRAY) +
    style_color(BLACK) +
    style_text_align("center")
  end

  def th_large
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(GRAY) +
    style_color(BLACK) +
    style_font("normal","bold","1.000em","Georgia,serif") +
    style_text_align("center")
  end

  def th_justify
    style_text_align("justify")
  end

  def th_total
    style_text_align("right")
  end

  def th_totalamount
    style_text_align("left")
  end

  def td_default
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_bg_color(WHITE) +
    style_color(BLACK) +
    style_text_align("left")
  end

  def td_grouping
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_color(BLACK) +
    style_text_align("left")
  end

  def td_large
    style_border_width(1) +
    style_border_style("solid") +
    style_border_color(BLACK) +
    style_color(BLACK) +
    style_font("normal","normal","1.000em","Georgia,serif") +
    style_text_align("left")
  end

  def td_even
    style_bg_color(GAINSBORO)
  end

  def td_grouping_even
    style_bg_color(GAINSBORO)
  end

  def td_odd
    style_bg_color(DARKGRAY)
  end

  def td_grouping_odd
    style_bg_color(DARKGRAY)
  end

  def td_team
    style_bg_color(YELLOW)
  end

  def td_highlight_bad
    style_bg_color(RED)
  end

  def td_highlight_good
    style_bg_color(LIME)
  end

  def td_ordinal
    style_text_align("center")
  end

  def td_number
    style_text_align("right")
  end

  def td_text
    style_text_align("left")
  end

  def td_justify
    style_text_align("justify")
  end
end
