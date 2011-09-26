module CosmicWimpout
  module Publisher
    
    def publish_to(subscriber)
      @subscriber = subscriber
    end
    
    def publish(message, *args)
      @subscriber.send(message, *args) if @subscriber
    end
  end
end
