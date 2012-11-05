require 'cinch'
require 'yaml'

# DAMON DATA ------
data = YAML.load_file('data.yaml')
reps = 15 # TODO: don't hard code this; increase by 5 every 2 hours or something

Quotes = data['inspiration']
Exercises = data['exercises']

FileWorkdayFlag = "workday.flag"
FileExerciseFlag = "exercise.flag"
FilePickExerciseFlag = "pick_new_exercise.flag"

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
        c.server = "irc.freenode.org"
        c.nick = "MattDaemon"
        c.channels = ["#cinch-bots"]
    end

    on :message, "subscribe" do |m|
        nick = m.user.nick
        if subscriberList.include?(nick)
            m.reply "I like your enthusiasm, #{nick}, but you're already on the list. MattDaemon still loves you."
        else
            subscriberList << nick 
            saveSubscribers(subscriberList)
            m.reply "#{nick} will be notified of exercise times. MattDaemon loves you."
        end
    end

    on :message, "unsubscribe" do |m|
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

    # DEBUG exercises
    on :message, "exercise" do |m|
        doExercise(m)
    end
end

bot.start
