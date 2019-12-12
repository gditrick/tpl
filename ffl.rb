#!/usr/bin/env ruby
# == Synopsis
#
# ffl: reads in db.yml and will e-mail reminders and results to teams
#
# == Usage
#
#  ffl [-h|--help] [-w|--week <num>]
#    -h | --help        - Help. Gives this output.
#    -w | --week <num>  - week number to send result email.
configPath  =  File.join(File.dirname(__FILE__), "config")
dbPath      =  File.join(File.dirname(__FILE__), "db")

helpersPath =  File.join(File.dirname(__FILE__), "helpers")
modelsPath  =  File.join(File.dirname(__FILE__), "models")
#vendorPath  =  File.join(File.dirname(__FILE__), "vendor")

#ENV['GEM_HOME'] = File.join(vendorPath,  "gems", RUBY_VERSION)

#Dir.glob(File.join(vendorPath, "**", "lib" )).each do |dir| $: << dir end

require 'getoptlong'
require 'linguistics'
require 'net/http'
require 'active_support'
require 'active_support/core_ext'
require 'action_mailer'
require 'yaml'
require 'time'
require 'pp'

Linguistics::use( :en )

config =  {}
config.merge!(YAML.load(File.read(File.join(configPath, "email.yml"))).symbolize_keys!)

config[:action_mailer].symbolize_keys!

ActionMailer::Base.delivery_method    =
  config[:action_mailer][:delivery_method].nil? ?
    :sendmail : config[:action_mailer][:delivery_method]
ActionMailer::Base.perform_deliveries =
  config[:action_mailer][:perform_deliveries].nil? ?
    false : config[:action_mailer][:perform_deliveries]

if ActionMailer::Base.delivery_method != "test"
  if config[:action_mailer]["#{ActionMailer::Base.delivery_method.to_s}_settings".to_sym].nil?
    ActionMailer::Base.delivery_method    = :test
    ActionMailer::Base.perform_deliveries = false
  else
    eval("ActionMailer::Base.#{ActionMailer::Base.delivery_method}_settings = #{config[:action_mailer]["#{ActionMailer::Base.delivery_method}_settings".to_sym].symbolize_keys}")
  end
end

#ActionMailer::Base.template_root =
#  config[:action_mailer][:template_root].nil? ?
#    File.join(File.dirname(__FILE__), "views") :
#    File.join(File.dirname(__FILE__), eval(config[:action_mailer][:template_root]))

Dir.glob(File.join(helpersPath, "*.rb")).sort.each do |f| load(f) end

Dir.glob(File.join(modelsPath, "*.rb")).sort.each do |f| load(f) end

USAGE = <<-EOF
  #{File.basename($0)} [-h|--help] [-w|--week <num>]
    -h | --help        - Help. Gives this output.
    -w | --week <num>  - week number of the results.  Defaults to previous week.
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

yaml_files = Dir.glob(File.join(configPath, "*.yml"))

yaml_files.each do |file|
  config.merge!(YAML.load(File.read(file)).symbolize_keys!)
end

data   = YamlData.new(dbPath)

League.new(config[:league], data.teams.size)

teams = data.teams
week  = data.seasons[0].weeks.find_by_pos(week_num) unless week_num.nil?
week  = data.seasons[0].weeks.current if week.nil?

previous_week = week.nil? ? data.seasons[0].weeks.last : week.previous_week

unless previous_week.nil?
  if previous_week.send_results?
    data.write(dbPath)
    data.gzip(dbPath)
    puts "Send Results..."
    previous_week.scores.each do |score|
      unless score.total == 0
        Mailer.with(score: score,
                    week: previous_week,
                    season: data.seasons.first,
                    prize_definition: League.prize_definition,
                    gz_yaml_file: File.join(dbPath, "db.yml.gz")
        ).results.deliver_now
      end
    end

    data.winnings.select_by_period(previous_week).each do |winning|
      Mailer.with(winning: winning).winner.deliver_now
    end

    if previous_week.is_end_of_quarter?
      puts "End of " + previous_week.quarter.description

      data.winnings.select_by_period(previous_week.quarter).each do |winning|
        Mailer.with(winning: winning).winner.deliver_now
      end
    end

    if previous_week.is_end_of_half?
      puts "End of " + previous_week.half.description

      data.winnings.select_by_period(previous_week.half).each do |winning|
        Mailer.with(winning: winning).winner.deliver_now
      end
    end

    if previous_week.is_end_of_season?
      puts "End of " + previous_week.season.description

      data.winnings.select_by_period(previous_week.season).each do |winning|
        Mailer.with(winning: winning).winner.deliver_now
      end
    end

    previous_week.results_sent_at = Time.now
    data.write(dbPath)
  end
end

unless week.nil?
  if week.send_lineup_reminder?
    puts "Sending Line-up Reminders..."
    teams.each do |team|
      if previous_week.nil?
        Mailer.with(team: team,
                    week: week,
                    previous_week: previous_week,
                    season: data.seasons.first,
                    prize_definition: League.prize_definition
        ).lineups.deliver_now
      elsif previous_week.find_score_by_team(team).total > 0.0
        Mailer.with(team: team,
                    week: week,
                    previous_week: previous_week,
                    season: data.seasons.first,
                    prize_definition: League.prize_definition
        ).lineups.deliver_now
      end
    end
    week.lineups_sent_at = Time.now
    data.write(dbPath)
    data.gzip(dbPath)
  end
end

if ActionMailer::Base.delivery_method.eql?("test")
  ActionMailer::Base.deliveries.count

  ActionMailer::Base.deliveries.each do |tmail|
    puts tmail.to_s
  end
end
