require 'cinch'
require 'yaml'

# DAMON CONFIG ------
config = YAML.load_file('config.yaml')

Quotes = config['inspiration']
Exercises = config['exercises']
Server = config['server']
Nick = config['nick']
Channels = config['channels']
CommandHelp = "!subscribe, !unsubscribe, quote, !add_exercise, !remove_exercise, !gtfo"
FileWorkdayFlag = "workday.flag"
FileExerciseFlag = "exercise.flag"
FilePickExerciseFlag = "pick_new_exercise.flag"

reps = 15 # TODO: don't hard code this; increase by 5 every 2 hours or something


# SUBSCRIBER DATA ------
if File.exist?('subscribers.yaml')
    subscriberList = YAML.load_file('subscribers.yaml')
else
    subscriberList = [] 
end


# helper methods ------
def saveSubscribers(list)
    File.open('subscribers.yaml', 'w+') { |out|
        YAML::dump(list, out)
    }
end
def inspire(m)
    quote = Quotes.sample
    m.reply "\"#{quote}\" - Matt Damon" 
end
def doExercise(m)
    peeps = subscriberList.join(",")
    exercise = Exercises.sample
    if subscriberList.any?
        inspire(m)
        m.reply "#{peeps}\: Do #{reps} #{exercise}!" 
    end
end


# MattDaemon ------
bot = Cinch::Bot.new do
    configure do |c|
        c.server = Server 
        c.nick = Nick 
        c.channels = Channels 
    end

    on :message, "!subscribe" do |m|
        nick = m.user.nick
        if subscriberList.include?(nick)
            m.reply "I like your enthusiasm, #{nick}, but you're already on the list. MattDaemon still loves you."
        else
            subscriberList << nick 
            saveSubscribers(subscriberList)
            m.reply "#{nick} will be notified of exercise times. MattDaemon loves you."
        end
    end

    on :message, "!unsubscribe" do |m|
        nick = m.user.nick
        if subscriberList.include?(nick)
            subscriberList.delete(nick)
            saveSubscribers(subscriberList)
            m.reply "You suck, #{nick}."
        else
            m.reply "You're not on the list, #{nick}. You suck."
        end
    end

    # on demand inspiration!
    on :message, "quote" do |m|
        inspire(m)
    end

    # help/commands list
    on :message, "MattDaemon" do |m|
        m.reply "Type \"MattDaemon help\" or \"!help\" for a list of commands"
    end
    on :message, "MattDaemon help" do |m|
        m.reply CommandHelp
    end
    on :message, "!help" do |m|
        m.reply CommandHelp
    end

    # add/remove exercieses
    on :message, "!add_exercise" do |m|
        m.reply "NOPE"
    end
    on :message, "!remove_exercise" do |m|
        m.reply "NOPE"
    end
    on :message, "!gtfo" do |m|
        m.reply "NOPE"
    end

    # DEBUG exercises
    on :message, "exercise" do |m|
        doExercise(m)
    end
end

bot.start
