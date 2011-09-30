require_relative 'cosmic_wimpout/game'
require_relative 'cosmic_wimpout/player'
require_relative 'cosmic_wimpout/cube'
require_relative 'cosmic_wimpout/scorer'
require_relative 'cosmic_wimpout/toss'
require_relative 'cosmic_wimpout/controller'
require_relative 'cosmic_wimpout/views/start_view'
require_relative 'cosmic_wimpout/views/player_view'
require_relative 'cosmic_wimpout/views/turn_view'

module CosmicWimpout

  def self.start
    Controller.start
  end
  
end
