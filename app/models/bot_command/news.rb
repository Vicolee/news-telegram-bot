require 'telegram/bot'

module BotCommand
  class News < Base
    attr_reader :user, :message, :api, :coins
    attr_accessor :coin_list

    def initialize(message, user)
      # Update this coin list if any changes to available coin list
      @coins = ['BTC', 'BCH', 'ETH', 'LTC', 'XLM', 'XRP', 'BAT', 'USDT', 'USDC', 'ZIL', 'BNB', 'NEO']
      token = Rails.application.credentials.telegram[:bot]
      @api = Telegram::Bot::Api.new(token)
      @message = message
      @user = user
    end

    # To produce the keyboard markup of the list of available coins on platform.
    # Users to select from the list and bot will start sending periodic updates
    # based on the user's selection.
    # def get_crypto_list_keyboard
    #   question = 'Select the coins you are interested in hearing about'
    #   coin_markups = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
    #                 keyboard: @coins,
    #                 one_time_keyboard: false)
    #   send_markup(question, coin_markups)
    # end

    # Displays the inline keyboard markup to retrieve user's desired list of coin news for tracking.
    def get_crypto_list_inline
      question = 'Select the coins you are interested in hearing about. Press on the coin again to remove from your list. Type /coinlist to verify your new coin list.'
      keys = [
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[0], callback_data: @coins[0]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[1], callback_data: @coins[1]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[2], callback_data: @coins[2]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[3], callback_data: @coins[3]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[4], callback_data: @coins[4]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[5], callback_data: @coins[5]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[6], callback_data: @coins[6]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[7], callback_data: @coins[7]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[8], callback_data: @coins[8]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[9], callback_data: @coins[9]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[10], callback_data: @coins[10]),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: @coins[11], callback_data: @coins[11]),
              ]
      coin_markups = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keys)
      send_markup(question, coin_markups)
    end

    # Stores the coin into the user's database. Remove coin if it
    def store_coin(coin, callback_query_id)
      if @user.coin_list.blank?
        puts "#{@user.first_name} coin list is empty. Now creating list..."
        user_coin_list = [coin]
        @user.update(coin_list: user_coin_list) # Initializes coin selected into user's coin_list
        notify_coin_added(coin, callback_query_id)  # Answers Callback Query, informs user that coin has been added.
        puts "#{@user.first_name} (telegram id: #{@user.telegram_id}) current coin list is #{@user.coin_list}"
      else
        if @user.coin_list.include?(coin)
          puts "Removing #{coin} from #{@user.first_name} (telegram id: #{@user.telegram_id}) current coin List: #{@user.coin_list}..."
          @user.coin_list.delete(coin) # Removes selected coin from list
          @user.save                   # Saves new coin list into database
          notify_coin_removed(coin, callback_query_id) # Informs user that coin has been removed from user's list.
          puts "Removed #{coin} from #{@user.first_name} coin list. Current coin list: #{@user.coin_list}"
        else
          puts "Adding #{coin} to #{@user.first_name} (telegram id: #{@user.telegram_id}) current coin List: #{@user.coin_list}."
          user_coin_list = @user.coin_list << coin # Add selected coin to user's coin list.
          @user.update(coin_list: user_coin_list)  # Saves new coin list to database.
          notify_coin_added(coin, callback_query_id)  # Informs user that coin has been added to user's list.
          puts "Added #{coin} to #{@user.first_name} coin list. Current coin list: #{@user.coin_list}"
        end
      end
    end

    def current_coin_list
      if @user.coin_list.nil? || @user.coin_list.empty?
        send_message("Hello #{@user.first_name}! Your coin list is currently empty. Please use /news to add coins.")
      else
        coin_count = @user.coin_list.count()
        total_coins = @coins.length()
        message = "Congratulations #{@user.first_name}, you are currently subscribed to *#{coin_count}/#{total_coins}* of the coins. They are: *#{@user.coin_list.join(", ")}*. I will deliver to you news relating to these coins as soon as they are available. Type /news if you want to make any changes."
        @api.call('sendMessage', chat_id: @user.telegram_id, text: message, parse_mode: 'Markdown')
      end
    end
    # Informs user about whether a coin was deleted or added to his database from callback query action.
    def notify_coin_added(coin, callback_id)
      @api.call('answerCallbackQuery', callback_query_id: callback_id, text: "Added #{coin}. Coins: #{@user.coin_list.join(", ")}")
      puts "#{@user.first_name} (telegram id: #{@user.telegram_id}) added #{coin} to his list"
    end

    def notify_coin_removed(coin, callback_id)
      if @user.coin_list.nil? || @user.coin_list.empty?
        @api.call('answerCallbackQuery', callback_query_id: callback_id, text: "Removed #{coin}. Your coin list is empty.")
      else
        @api.call('answerCallbackQuery', callback_query_id: callback_id, text: "Removed #{coin}. Coins: #{@user.coin_list.join(", ")}")
      end
      puts "#{@user.first_name} (telegram id: #{@user.telegram_id}) removed #{coin} from his list"
    end

    def send_markup(text, markup, options={})
      @api.call('sendMessage', chat_id: @user.telegram_id, text: text, reply_markup: markup)
    end
  end
end
