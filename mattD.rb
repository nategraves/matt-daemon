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
FileWorkdayFlag = "workday.flag"
FileExerciseFlag = "exercise.flag"
FilePickExerciseFlag = "pick_new_exercise.flag"

$reps = 15 # TODO: maybe don't hard code this; increase by 5 every 2 hours or something
$currentExercise = Exercises.sample


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
    if $subscriberList.any?
        msg = "#{peeps}\: Do #{$reps} #{$currentExercise}!" 
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
    $matt.start
end


# SCHEDULING  ------
while true do

    # fire off the exercise message
    if File.exist?(FileExerciseFlag)
        getRipped(nil)
        File.delete(FileExerciseFlag)
    end

    # pick a new exercise
    #if File.exist?(FilePickExerciseFlag)
        #currentExercise = Exercises.sample
    #end

    sleep(SleepInterval)
end
