require 'cinch'
require 'yaml'

data = YAML.load_file('quotes.yaml')

Quotes = data['inspiration']
Exercises = data['exercises']

bot = Cinch::Bot.new do
    configure do |c|
        c.server = "irc.freenode.org"
        c.nick = "MattDaemon"
        c.channels = ["#cinch-bots"]
    end

    on :message, "hello" do |m|
        m.reply "Hello, #{m.user.nick}"
    end

    on :message, "quote" do |m|
        quote = Quotes.sample
        m.reply "\"#{quote}\" - Matt Damon" 
    end

    on :message, "exercise" do |m|
        exercise = Exercises.sample
        reps = 15 # TODO: don't hard code this
        m.reply "Do #{reps} #{exercise}" 
    end
end

bot.start
