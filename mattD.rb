require 'cinch'
require 'yaml'

# CONFIG ------
$config = YAML.load_file('config/config.yaml')

Quotes = $config['inspiration']
Exercises = $config['exercises']
Server = $config['server']
Nick = $config['nick']
Channels = $config['channels']
SleepInterval = $config['sleep']
CommandHelp = "!subscribe, !unsubscribe, quote, !gtfo"
FlagWorkday = "workday.flag"
FlagWeekend = "weekend.flag"
FlagExercise = "exercise.flag"
FlagPickExercise = "pick_new_exercise.flag"

$reps = 15 # TODO: maybe don't hard code this; increase by 5 every 2 hours or something
$currentExercise = nil


# SUBSCRIBER DATA ------
if File.exist?('subscribers.yaml')
    $subscriberList = YAML.load_file('subscribers.yaml')
else
    $subscriberList = [] 
end


# helper methods ------
def say(message)
    if $matt.channels.any?
        $config["channels"].each do |chan|
            $matt.Channel(chan).msg message
        end
    end
end

def saveSubscribers(list)
    File.open('subscribers.yaml', 'w+') { |out|
        YAML::dump(list, out)
    }
end

# TODO: make these generic messages instead of replies
def inspire(m)
    quote = Quotes.sample
    msg = "\"#{quote}\" - Matt Damon" 
    if m
        m.reply msg
    else
        say msg 
    end
end

def getRipped(m)
    peeps = $subscriberList.join(",")
    $currentExercise ||= Exercises.sample
    if $subscriberList.any?
        msg = "#{peeps}\: Do #{$reps} #{exercise}!" 
        if m
            inspire(m)
            m.reply msg
        else
            inspire(nil)
            say msg 
        end
    end
end


# MattDaemon ------
$matt = Cinch::Bot.new do
    configure do |c|
        c.server = Server 
        c.nick = Nick 
        c.channels = Channels 
    end

    on :message, "!subscribe" do |m|
        nick = m.user.nick
        if $subscriberList.include?(nick)
            m.reply "I like your enthusiasm, #{nick}, but you're already on the list. MattDaemon still loves you."
        else
            $subscriberList << nick 
            saveSubscribers($subscriberList)
            m.reply "#{nick} will be notified of exercise times. MattDaemon loves you."
        end
    end

    on :message, "\!unsubscribe" do |m|
        nick = m.user.nick
        if $subscriberList.include?(nick)
            $subscriberList.delete(nick)
            saveSubscribers($subscriberList)
            m.reply "You suck, #{nick}."
        else
            m.reply "You're not on the list, #{nick}. You suck."
        end
    end

    # on demand inspiration!
    on :message, "quote" do |m|
        inspire(m)
    end

    on :message, "!exercise" do |m|
        getRipped(m)
    end

    # help/commands list
    on :message, "MattDaemon" do |m|
        m.reply "Type \"!mattHelp\" for a list of commands"
    end
    on :message, "!mattHelp" do |m|
        m.reply CommandHelp
    end

    # TODO: make this work
    # add/remove exercieses
    #on :message, "!add_exercise" do |m|
        #m.reply "NOPE"
    #end
    #on :message, "!remove_exercise" do |m|
        #m.reply "NOPE"
    #end
    #on :message, "!gtfo" do |m|
        #m.reply "NOPE"
    #end
end

Thread.new do
    #$matt.start
end


# SCHEDULING  ------
while true do

    # no getting ripped on the weekend
    if !File.exist?(FlagWeekend)

        # fire off the exercise message
        # during workday only 
        if File.exist?(FlagWorkday)
            if File.exist?(FlagExercise) 
                getRipped(nil)
                File.delete(FlagExercise)
            end
        end

        # pick new exercise each day
        if File.exist?(FlagPickExercise)
            $currentExercise = Exercises.sample
            File.delete(FlagPickExercise)
        end

    end

    sleep(SleepInterval)
end
