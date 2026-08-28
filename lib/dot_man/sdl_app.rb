# frozen_string_literal: true

require "sdl2"

module DotMan
  class SDLApp
    WIDTH = 800
    HEIGHT = 600
    TARGET_FRAME_SECONDS = 1.0 / 60.0
    MAX_DELTA_SECONDS = 0.1
    BACKGROUND = [4, 6, 15, 255].freeze

    def initialize
      @animation = Animation.new(seconds_per_turn: 4.0)
      @projector = Projector.new(width: WIDTH, height: HEIGHT)
      @points = Mannequin.points
      @running = true
    end

    def run
      SDL2.init(SDL2::INIT_VIDEO | SDL2::INIT_EVENTS)
      window = SDL2::Window.create(
        "Rotating Dot Man",
        SDL2::Window::POS_CENTERED,
        SDL2::Window::POS_CENTERED,
        WIDTH,
        HEIGHT,
        0
      )
      renderer = window.create_renderer(-1, 0)
      renderer.draw_blend_mode = SDL2::BlendMode::BLEND

      started_at = monotonic_time
      previous_frame_at = started_at

      while @running
        frame_started_at = monotonic_time
        delta = [frame_started_at - previous_frame_at, MAX_DELTA_SECONDS].min
        previous_frame_at = frame_started_at

        handle_events
        @animation.update(delta)
        render(renderer, frame_started_at - started_at)
        pace_frame(frame_started_at)
      end
    rescue Interrupt
      @running = false
    ensure
      SDL2.quit if SDL2.respond_to?(:quit)
    end

    private

    def handle_events
      while (event = SDL2::Event.poll)
        case event
        when SDL2::Event::Quit
          @running = false
        when SDL2::Event::KeyDown
          next if event.repeat

          case event.scancode
          when SDL2::Key::Scan::SPACE
            @animation.toggle
          when SDL2::Key::Scan::ESCAPE
            @running = false
          end
        end
      end
    end

    def render(renderer, elapsed_seconds)
      renderer.draw_color = BACKGROUND
      renderer.clear

      @projector.project(@points, @animation.angle).each do |point|
        renderer.draw_color = Rainbow.color(point, elapsed_seconds)
        size = point.size
        renderer.fill_rect(SDL2::Rect.new(
          (point.x - size / 2.0).round,
          (point.y - size / 2.0).round,
          size,
          size
        ))
      end

      renderer.present
    end

    def pace_frame(frame_started_at)
      remaining = TARGET_FRAME_SECONDS - (monotonic_time - frame_started_at)
      sleep(remaining) if remaining.positive?
    end

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
