require 'active_support'
require 'cinch'
require 'yaml'

data = YAML.load_file('quotes.yaml')

Quotes = data['inspiration']
Exercises = data['exercises']

# TODO: dump this in yaml so we have it if the pipe breaks
subscribers = [] 

bot = Cinch::Bot.new do
    configure do |c|
        c.server = "irc.freenode.org"
        c.nick = "MattDaemon"
        c.channels = ["#cinch-bots"]
    end

    # subscription
    on :message, "subscribe" do |m|
        subscribers << m.user.nick 
        m.reply "You're in."
    end
    on :message, "unsubscribe" do |m|
        subscribers.delete(m.user.nick)
        m.reply "You're out."
    end

    # DEBUG quotes
    on :message, "quote" do |m|
        quote = Quotes.sample
        m.reply "\"#{quote}\" - Matt Damon" 
    end

    # DEBUG exercises
    on :message, "exercise" do |m|
        peeps = subscribers.join(",")
        exercise = Exercises.sample
        reps = 15 # TODO: don't hard code this
        m.reply "#{peeps}\: Do #{reps} #{exercise}!" 
    end
end

bot.start
