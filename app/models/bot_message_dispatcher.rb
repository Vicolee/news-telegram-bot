# frozen_string_literal: false
# This class is used to process incoming message and validate if command exists.
# If exists, run bot's command.
class BotMessageDispatcher
  attr_reader :coin, :callback_query_id

  def initialize(webhook, user)
    # Converts webhook to the actual commands sent by the user (either callback
    # query or regular commands like /start)
    @webhook = webhook
    if @webhook == 'Unsuccessful Registration'
      @message = @webhook
    elsif @webhook.has_key?(:callback_query)
      @message = '/add_or_remove_coin'        # If coin already in list, remove coin. Else, append coin.
      @coin = webhook[:callback_query][:data] # Coin selected by user through inline markup
      @callback_query_id = webhook[:callback_query][:id]
    else
      @message = webhook[:message][:text]
    end
    @user = user
  end

  # This command is used to reply the user based on the user's message
  def reply
    if @message == '/start'
      start_command
    elsif @message == '/resume'
      resume_command
    elsif @message == '/pause'
      pause_command
    elsif @message == '/checkstatus'
      check_status_command
    elsif @message == 'Unsuccessful Registration' && @user.first_name == 'Invalid User'
      fail_register
    elsif @message == '/help'
      help_command       # Lists available commands for users
    elsif @message == '/news'
      news_command       # Produces inline markup for users to pick coins.
    elsif @message == '/add_or_remove_coin'
      add_or_remove_coin # Adds or removes coin from User's list depending on existence of it in database.
    elsif @message == '/coinlist'
      list_user_coins # Lists user's current coin list.
    else
      invalid_command  # Asks user to use /help to see list of valid commands.
    end
  end

  private

  def list_user_coins
    bot_command = BotCommand::News.new(@message, @user)
    bot_command.current_coin_list
  end

  def start_command
    puts "#{@user.first_name} made '#{@message}' command."
    bot_command = BotCommand::Start.new(@message, @user)
    bot_command.start
  end

  def resume_command
    puts "#{@user.first_name} made '#{@message}' command."
    bot_command = BotCommand::Status.new(@message, @user)
    bot_command.resume
  end

  def pause_command
    puts "#{@user.first_name} made '#{@message}' command."
    bot_command = BotCommand::Status.new(@message, @user)
    bot_command.pause
  end

  def check_status_command
    puts "#{@user.first_name} made '#{@message}' command."
    bot_command = BotCommand::Status.new(@message, @user)
    bot_command.check_status
  end

  def help_command
    puts "#{@user.first_name} made '#{@message}' command."
    bot_command = BotCommand::Help.new(@message, @user)
    bot_command.help
  end

  def fail_register
    puts 'New user registered incorrectly.'
    bot_command = BotCommand::Undefined.new(@message, @user)
    bot_command.failed_registration
  end

  def invalid_command
    puts "#{@user.first_name} made an undefined '#{@message}' command."
    bot_command = BotCommand::Undefined.new(@message, @user)
    bot_command.invalid
  end

  def news_command
    puts "Collecting user's news now."
    bot_command = BotCommand::News.new(@message, @user)
    bot_command.get_crypto_list_inline
  end

  def add_or_remove_coin
    bot_command = BotCommand::News.new(@message, @user)
    bot_command.store_coin(@coin, @callback_query_id)
  end
end
