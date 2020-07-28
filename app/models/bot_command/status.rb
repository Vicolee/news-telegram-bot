module BotCommand
  class Status < Base
    def pause
      if @user.status == '/pause'
        send_message("Hi #{@user.first_name}. You have already paused the bot. Type /resume to start receiving news from the bot again.")
      else
        @user.update(status: '/pause')
        send_message("Hi #{@user.first_name}. I'm sorry to see you go. Type /resume to start receiving news from the bot again.")
      end
    end

    def resume
      if @user.status == '/resume'
        send_message("Hi #{@user.first_name}. Your bot has already been resumed. I will send to you the latest news whenever available. Type /coinlist to see what you are currently subscribed to.")
      else
        @user.update(status: '/resume')
        send_message("Congratulations #{@user.first_name}! Your bot has been resumed. I will send to you the latest news whenever available. Type /coinlist to see what you are currently subscribed to.")
      end
    end

    def check_status
      if @user.status == '/pause'
        send_message("Hi #{@user.first_name}. Your bot is currently paused and will not be sending you any news. Type /resume to start receiving news again.")
      else
        send_message("Hi #{@user.first_name}. Your bot is already working hard to send you the latest news. Type /coinlist to see your current coin subscriptions.")
      end
    end
  end
end
