module BotCommand
  class Help < Base
    def initialize(user, message)
      super
      # Note: For description, keep within 5 words.
      @commands = [{'start' => 'Register your account'},
                   {'news' => 'Subscribe to reliable crypto news'},
                   {'coinlist' => 'Get your subscription coin list'},
                   {'resume' => 'Allow bot to send news'},
                   {'pause' => 'Stop bot from sending news'},
                   {'checkstatus' => 'Check your news bot\'s status'},
                   {'help' => 'List commands and their descriptions'}]
    end

    def help
      send_message("Below are some cool things you can do:\n
/news - Get reliable news from official news sources. Use this command to subscribe or unsubscribe from coins.\n
/coinlist - Get the list of coins you're currently subscribed to.\n
/resume - Allow the bot to continue sending news to you. Do this only if you have paused the bot.\n
/pause - Stop the sending of news to you.\n
/checkstatus - Check if you are currently using our news bot or if you are currently paused.")
    end

    # setup method is for outputting instructions to the terminal to set up suggested commands
    # for bot when users type '/' in telegram.
    def setup
      @commands.each do |command|
        commands_description = "#{command.keys.join(',')}" + ' - ' + "#{command.values.join(',')}\n"
        puts commands_description.delete ""
      end
    end
  end
end
