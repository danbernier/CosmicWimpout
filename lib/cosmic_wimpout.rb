require_relative 'cosmic_wimpout/game'
require_relative 'cosmic_wimpout/controller'
require_relative 'cosmic_wimpout/view'
require_relative 'cosmic_wimpout/player_view'

module CosmicWimpout

  def self.start
    Controller.start
  end
  
end
