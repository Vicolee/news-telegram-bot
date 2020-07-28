module BotCommand
  class Start < Base
    def start
      @user.update(status: '/resume')
      send_message("Hello #{@user.first_name}! Welcome to bot. Type /help to see what you can do!")
    end
  end
end
