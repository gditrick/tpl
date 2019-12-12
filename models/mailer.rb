require 'action_mailer'

class Mailer < ActionMailer::Base
  add_template_helper(MailerHelper)
  
  prepend_view_path "views"

  default from:  "TPL Commissioner <gditrick@fuse.net>"

  def lineups
    @team = params[:team]
    @week = params[:week]
    @previous_week = params[:previous_week]
    @season = params[:season]
    @prize_definition = params[:prize_definition]

    to = @team.email.split(";")
    #to = 'gditrick@fuse.net'
    subject =  "TPL: Start of #{@week.description} Is Fast Approaching"

    mail(to: to, subject: subject)
  end

  def results
    @score = params[:score]
    @team = @score.team
    @week = params[:week]
    @season = params[:season]
    @prize_definition = params[:prize_definition]

    to = @team.try(:email).try(:split, ";")
    #to = 'gditrick@fuse.net'
    subject =  "TPL: #{params[:week].try(:description)} Results"

    attachments[File.basename(params[:gz_yaml_file])] =
      File.read(params[:gz_yaml_file]) if params[:gz_yaml_file] && File.exist?(params[:gz_yaml_file])

    attachments[File.basename(params[:xls_file])] =
      File.read(params[:xls_file]) if params[:xls_file] && File.exist?(params[:xls_file])

    mail(to: to, subject: subject)
  end

  def toilet_bowl_results(team, week, score, prize_definition, idx, gz_yaml_file=nil, xls_file=nil)
#    recipients    "nditrick@fuse.net"
#    recipients    "gditrick@fuse.net;gregd@ditrick.net".split(";")
    recipients    team.email.split(";")
    subject       "FFL: #{week.description} Results"
    cc            "FFL Commissioner <gditrick@fuse.net>" if idx == 1
    content_type  "multipart/mixed"

    part :content_type => "multipart/alternative" do |a|
      a.part "text/html" do |p|
        p.body = render_message("results_toiletbowl.text.html",
                                :team => team,
                                :score => score,
                                :week => week,
                                :prize_definition => prize_definition
        )
        p.transfer_encoding = "base64"
      end

      a.part "text/plain" do |p|
        p.body = render_message("results_toiletbowl.text.plain",
                                :team => team,
                                :score => score,
                                :week => week,
                                :prize_definition => prize_definition
        )
      end
    end

    attachment :content_type => "application/z-gzip",
               :filename => File.basename(gz_yaml_file),
               :body => File.read(gz_yaml_file) if File.exist?(gz_yaml_file) unless gz_yaml_file.nil?

    attachment :content_type =>  "application/vnd.ms-excel",
               :filename => File.basename(xls_file),
               :body => File.read(xls_file) if File.exist?(xls_file) unless xls_file.nil?
  end

  def toilet_bowl_winner(winning)
#    recipients    "nditrick@fuse.net"
#    recipients    "gditrick@fuse.net;gregd@ditrick.net".split(";")
    recipients    winning.team.email.split(";")
    cc            "FFL Commissioner <gditrick@fuse.net>"
    subject       "FFL: #{winning.period.description} #{winning.prize.description} of #{winning.prize.class.name.titleize.split.slice(1..-2).join(' ')}"
    content_type  "multipart/alternative"

    part "text/html" do |p|
      p.body = render_message("winner.text.html", :winning => winning)
      p.transfer_encoding = "base64"
    end

    part "text/plain" do |p|
      p.body = render_message("winner.text.plain", :winning => winning)
    end
  end

  def winner
    @winning = params[:winning]

    if @winning
      to = @winning.try(:team).try(:email).try(:split, ";")
      #to = 'gditrick@fuse.net'
      cc = "TPL Commissioner <gditrick@fuse.net>"
      subject = "TPL: #{@winning.try(:period).try(:description)} " +
              "#{@winning.try(:prize).try(:description)} of " +
              "#{@winning.try(:prize).try(:class).try(:name).try(:titleize).try(:split).try(:slice, 1..-2).try(:join,' ')}"

      mail(to: to, cc: cc, subject: subject)
    end
  end

  def summary(team, winnings, season)
#    recipients    "gditrick@fuse.net"
    recipients    team.email.split(";")
    subject       "TPL: #{season.description} Summary"
    content_type  "multipart/alternative"

    part "text/html" do |p|
      p.body = render_message("summary.text.html", :team => team, :winnings => winnings, :season => season)
      p.transfer_encoding = "base64"
    end

   # part "text/plain" do |p|
   #   p.body = render_message("summary.text.plain", :winning => winning)
   # end
  end
end
