# tpl
Fantasy Football Total Points League 


Fantasy Footbal Email Application.

Description:
  Applications to handle managing a player survival league.  The web site,
  www.fanstar.com, does not provide the ability to break results into
  periods like quarters or halves.  I needed the ability to grab the results
  of each week and calculate and capture the results for such periods.
  Then email this to the participants.  I decided to use the ruby language
  with some rails framework, because of the available ruby libraries (gems)
  to make the emailing rendering easier.  I also decide a flat file database
  would be fine for this because there is no need for concurrent access or
  for the database to be up all the time.  This is a simple batch process
  that will run once a week to capture the results.  What better flat file
  database format to use than YAML since it is readable and Ruby objects can
  be stored in it easily.

Dependencies:
  Ruby >= 1.9.1
  Gems -
    linguistics >= 1.0.6.1 (eviltrout-linguistics from github) 
    actionmailer >= 2.3.4
    actionpack >= 2.3.4
    activesupport >= 2.3.4

Files:
  ./addr.rb                - Ruby Application that will add a weeks results to
                             the YAML db.
  ./config/league.yml      - League configurations like site, fees, cost,
                             prizes, etc.
  ./config/email.yml       - ActionMailer configurations.
  ./db/001teams*.yml       - Initial team DB and any historical changes. 
  ./db/002sched.yml        - Initial NFL schedule DB. 
  ./db/db.yml              - Current YAML DB of teams, schedule and results.
  ./ffl.rb                 - Ruby Application that will mail lineup reminder,
                             results, and winner emails.
  ./helpers                - Ruby helpers to extend classes, add modules, etc.
                             This is for the ruby on rails niceties.
  ./models                 - Ruby classes used by the apps.
  ./README                 - This file.
  ./stage/results*.txt     - Results files.  Since the site does not offer
                             results in xml, yaml, etc. and has a lot of
                             javacript that would be nasty to parse, copying
                             the results into a text file was the best option.
                             These files contain the staged results text from
                             the site.
  ./vendor/gems/1.9.1/gems - Location for required rubygems. Apps set GEM_HOME
                             to this.
  ./views/mailer           - Location for the ActionMailer email templates.


TODO:
  - Add in a y2xls app to create an Excel spreadsheet of the results since most 
    participants use windows and Excel is easier for them than YAML. The
    produced emails are okay for now, but I'm sure it would be nice to have a
    supporting document other than the YAML db for the participants.
  - Add in rspec and rcov and test cases.  This should have been done from the
    beginning (TDD/BDD), but it was not due to time to deliver the first cut.
