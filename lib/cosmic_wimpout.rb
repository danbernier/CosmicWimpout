require_relative 'cosmic_wimpout/game'
require_relative 'cosmic_wimpout/controllers/start_controller'
require_relative 'cosmic_wimpout/controllers/turn_controller'
require_relative 'cosmic_wimpout/view'
require_relative 'cosmic_wimpout/player_view'

module CosmicWimpout

  def self.start
    Controllers::StartController.start
  end
  
end
