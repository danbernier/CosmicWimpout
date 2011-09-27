module CosmicWimpout
  module Publisher
    
    def publish_to(subscriber)
      @subscriber = subscriber
    end
    
    def publish(message, *args)
      if @subscriber && @subscriber.respond_to?(message)
        @subscriber.send(message, *args)
      end
    end
  end
end
