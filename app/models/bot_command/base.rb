require 'telegram/bot'

module BotCommand
  class Base
    attr_reader :user, :message, :api

    def initialize(message, user)
      token = Rails.application.credentials.telegram[:bot]
      @api = Telegram::Bot::Api.new(token)
      @message = message
      @user = user
    end

    # Sending different types of messages back to user.
    def send_message(text, options={})
      @api.call('sendMessage', chat_id: @user.telegram_id, text: text)
    end
  end
end
