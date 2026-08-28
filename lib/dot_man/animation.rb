# frozen_string_literal: true

module DotMan
  class Animation
    FULL_TURN = Math::PI * 2.0

    attr_reader :angle

    def initialize(seconds_per_turn: 4.0)
      @angular_speed = FULL_TURN / seconds_per_turn
      @angle = 0.0
      @rotating = false
    end

    def rotating?
      @rotating
    end

    def toggle
      @rotating = !@rotating
    end

    def update(delta_seconds)
      return @angle unless rotating?

      @angle = (@angle + @angular_speed * delta_seconds) % FULL_TURN
    end
  end
end
