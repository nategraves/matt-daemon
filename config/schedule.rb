# shedules exercises for MattDaemon
# requires wheneverize
# writes a crontab with wheneverize -w

FlagPath = "~/dev/matt-daemon"

every :day, :at => '10:38pm' do
    command "echo exercise > #{path}/exercise.flag"
end

every :day, :at => '12:00am' do
    command "echo pick_new_exercise > #{path}/pick_new_exercise.flag"
end

# only run during the workday
every :day, :at => '10:15am' do
    command "echo workday > #{path}/workday.flag"
end

every :day, :at => '7:00pm' do
    command "rm #{path}/workday.flag" 
end
