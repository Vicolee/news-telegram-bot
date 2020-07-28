# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
Dir.glob('./app/models/bot_command/*.rb').each { |r| require r }

run Rails.application

commands = BotCommand::Help.new(nil, nil)
start =<<~START
================== Setup inline command suggestions ==================
Step 1: Send '/setcommands' to @BotFather on Telegram
Step 2: Select the bot to set the inline command suggestion
Step 3: Send the following to @BotFather
START
close =<<~END
================== Setup inline command suggestions ==================
END
puts start
commands.setup
puts close
