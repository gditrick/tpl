#!/usr/bin/env ruby
# == Synopsis
#
# addr: adds staged results file to db.yml taking care of any name changes
#
# == Usage
#
#  addr.rb [-h|--help] [-w <num>|--week=<num> --] [<from-file>]
#    -h | --help        - Help. Gives this output.
#    -w | --week <num>  - week number of the results.  Defaults to previous week.
#    <from-file>        - Text file that contains the results.
#                         Defaults to: ./stage/results<week>.txt
#                         If <week> = 1, then: /stage/results1.txt
require 'getoptlong'
require 'csv'

configPath  =  File.join(File.dirname(__FILE__), "config")
dbPath      =  File.join(File.dirname(__FILE__), "db")
stagePath   =  File.join(File.dirname(__FILE__), "stage")

helpersPath =  File.join(File.dirname(__FILE__), "helpers")
modelsPath  =  File.join(File.dirname(__FILE__), "models")

Dir.glob(File.join(helpersPath, "*.rb")).sort.each do |f| load(f) end

Dir.glob(File.join(modelsPath, "*.rb")).sort.each do |f| load(f) end

USAGE = <<-EOF
  #{File.basename($0)} [-h|--help] [-w|--week <num> --] [<from-file>]
    -h | --help        - Help. Gives this output.
    -w | --week <num>  - week number of the results.  Defaults to previous week.
    <from-file>        - Text file that contains the results.
                         Defaults to: #{File.join(stagePath,"results<week>.txt")}
                         If <week> = 1, then: #{File.join(stagePath, "results1.txt")}
EOF

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--week', '-w', GetoptLong::REQUIRED_ARGUMENT ]
)

week_num = nil
opts.each do |opt, arg|
  case opt
    when '--help'
      puts USAGE
      exit(1)
    when '--week'
      week_num = arg.to_i
  end
end

data   = YamlData.new(dbPath)

yaml_files = Dir.glob(File.join(configPath, "*.yml"))
config =  {}

yaml_files.each do |file|
  config.merge!(YAML.load(File.read(file)).symbolize_keys!)
end

League.new(config[:league], data.teams.size)

teams         = data.teams

case ARGV.size
when 0 then
  previous_week = data.seasons[0].weeks.find_by_pos(week_num) unless week_num.nil?
  previous_week = data.seasons[0].weeks.previous if previous_week.nil?
  from_file = File.join(stagePath,"results#{previous_week.pos}.txt")
when 1 then
  from_file = ARGV[0]
else
  puts USAGE
  exit(1)
end

from_file = File.exist?(from_file) ?
              from_file : File.exist?(File.join(stagePath, from_file)) ?
                            File.join(stagePath,from_file) : from_file

if not File.exist?(from_file)
  puts "<from-file> : #{from_file} does not exist."
  puts USAGE
  exit 1
end

rnames = ResultTxt.names(from_file)

unless rnames.sort == teams.names.sort
  puts "Some team names do not match.  Will try to fix..."
  mappings = TeamNameMappings.new(teams.names.sort - rnames.sort,
                                  rnames.sort - teams.names.sort)

  exit(0) if mappings.empty?

  mappings.fix_teams(teams)
  mappings.fix_result_files(stagePath, "results*.txt") #has to be done if results are ever re-ran i.e. -w option
  mappings.add_teams_file(dbPath, "*teams*.yml", teams) #historical purpose
end

weeks = week_num.nil? ? data.seasons[0].weeks : [data.seasons[0].weeks.find_by_pos(week_num)]

weeks.each do |week|
  from_file = File.join(stagePath,"results#{week.pos}.txt")

  scores = Scores.new

  if File.exist?(from_file) && (week.scores.nil? || week.scores.empty?)
    ResultTxt.records(from_file).each do |rec|
      scores << Score.new(teams.find_by_name(rec.name), week, rec.total.to_f.round(2))
    end

    week.post_scores(teams, scores)
  end

  if week.player_scores.nil? || week.player_scores.quarterbacks.empty?
    player_scores = PlayerScores.new
    %i[
        defenses
        defensivebacks
        defensivelinemen
        placekickers
        linebackers
        quarterbacks
        runningbacks
        tightends
        widereceivers].each do |player_group|

      from_file = player_group.to_s.singularize + '_results' + week.pos.to_s + '.csv'
      player_file = File.join(stagePath, from_file)
      if File.exists?(player_file)
        player_score_table = CSV.read(player_file)
        player_score_table.each do |player_row|
          player_score = PlayerScore.new
          player_score.last_name       = player_row[0]
          player_score.first_name      = player_row[1]
          player_score.position_abbrev = player_row[2]
          player_score.team_abbrev     = player_row[3]
          player_score.total           = player_row[5].blank? ? 0.0 : player_row[5].to_f.round(2)

          break if player_score.total <= 0.0

          player_scores.send(player_group).send(:<<, player_score)
        end
      end
    end

    week.player_scores = player_scores
  end
  break if week == previous_week
end



#Redo calc winnings since this could be a re-run...

#Reset counts for each team
data.teams.each do |team|
  team.winnings_count  = 0
  team.winnings_amount = 0.0
end

data.winnings = Winnings.new

data.seasons.first.weeks.each do |week|
  unless week.scores.nil? or week.scores.empty?
    skip_prizes = Prizes.new
    League.prize_definition.prizes.each do |prize|
      unless skip_prizes.nil? or skip_prizes.empty?
        if skip_prizes.include?(prize)
          skip_prizes.delete(prize)
          next
        end
      end

      case prize.period_type
      when "Week" then
        period       = week
        prize_scores = week.scores
      when "Quarter" then
        if week.is_end_of_quarter?
          period = week.quarter
          case prize
          when QuarterHighestWeeklyScorePrize then
            prize_scores = week.quarter.weekly_scores
          else
            prize_scores = week.quarter_scores
          end
        end
      when "Half" then
        if week.is_end_of_half?
          period = week.half
          case prize
          when HalfHighestWeeklyScorePrize then
            prize_scores = week.half.weekly_scores
          else
            prize_scores = week.half_scores
          end
        end
      when "Season" then
        if week.is_end_of_season?
          period = week.season
          case prize
          when SeasonHighestWeeklyScorePrize then
            prize_scores = week.season.weekly_scores
          else
            prize_scores = week.season_scores
          end
        end
      end
      unless prize_scores.nil? or prize_scores.empty?
        winning_scores = prize_scores.find_by_total(prize_scores[prize.offset].total)
        if winning_scores.size > 1
          combo_prize = CombinedPrize.new(prize)
          next_prize = prize
          count = 1
          cprize = combo_prize
          until next_prize.nil? or count >= winning_scores.size
            cprize.next_prize = next_prize.dup
            next_prize = next_prize.next_prize 
            skip_prizes << next_prize unless next_prize.nil?
            count += 1
          end
          prize = combo_prize
        end
        winning_scores.each do |winning_score|
          data.winnings << Winning.new(winning_score.team, prize, period, winning_score, winning_scores.size)
        end
      end
    end
  end
end

data.write(dbPath)
