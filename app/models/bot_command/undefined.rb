module BotCommand
  class Undefined < Base
    def invalid
      send_message("Sorry #{@user.first_name}, '#{@message}' is an invalid command. Type /help to see what you can do!")
    end

    def failed_registration
      send_message("Welcome to bot! Please begin registration by typing /start.")
    end
  end
end
