require 'cinch'
require 'yaml'

# DAMON CONFIG ------
config = YAML.load_file('config.yaml')

Quotes = config['inspiration']
Exercises = config['exercises']
Server = config['server']
Nick = config['nick']
Channels = config['channels']
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


# MattDaemon ------
bot = Cinch::Bot.new do
    configure do |c|
        c.server = Server 
        c.nick = Nick 
        c.channels = Channels 
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
        peeps = subscriberList.join(",")
        exercise = Exercises.sample
        if subscriberList.any?
            inspire(m)
            m.reply "#{peeps}\: Do #{reps} #{exercise}!" 
        end
    end
end

bot.start
