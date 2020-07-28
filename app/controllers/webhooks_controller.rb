# frozen_string_literal: false
require 'telegram/bot'

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    if User.exists?(telegram_id: from[:id])
      dispatcher.new(webhook, user).reply
    # Send a reply to user to register properly with /start command.
    else
      if message == '/start'
        register_user
      else
        @user = User.new(telegram_id: from[:id], first_name: 'Invalid User', step: 'Unsuccessful Registration')
        dispatcher.new(@user.step, @user).reply           # BotMessageDispatcher informs user about unsuccessful registration
      end
    end
  end

  def dispatcher
    BotMessageDispatcher
  end

  def webhook
    params['webhook']
  end

  def from
    if webhook.has_key?(:callback_query)
      webhook[:callback_query][:from]
    else
      webhook[:message][:from]
    end
  end

  def message
    if webhook.has_key?(:callback_query)
      return '/news'
    else
      webhook[:message][:text]
    end
  end

  # Find user. If can't find, register user in database.
  # Update First Name and Step(message) if changes.
  def user
    unless User.exists?(telegram_id: from[:id])
      register_user
    else
      @user = User.find_by(telegram_id: from[:id])
      if @user.update(first_name: from[:first_name], step: message)
        puts "Updated user #{@user.first_name} with telegram id #{@user.telegram_id}. Message: #{@user.step}."
      else
        @user.errors.full_messages
      end
    return @user
    end
  end

  def register_user
    @user = User.new(telegram_id: from[:id], first_name: from[:first_name], step: message, coin_list: [])
    if @user.save          # User must initialize by typing "/start". Otherwise, re-initialize
      puts "Created user #{@user.first_name} with telegram id #{@user.telegram_id}."
      dispatcher.new(webhook, user).reply
    else
      @user.errors.full_messages
    end
  end
end
