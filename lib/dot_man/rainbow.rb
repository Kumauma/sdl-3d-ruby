# frozen_string_literal: true

module DotMan
  module Rainbow
    module_function

    def color(point, elapsed_seconds)
      normalized_height = (point.world_y + 2.5) / 5.2
      hue = (elapsed_seconds / 6.0 + normalized_height * 0.62 + point.phase * 0.045) % 1.0
      depth_light = clamp(0.62 + (point.depth + 1.2) / 4.0, 0.50, 1.0)
      red, green, blue = hsv_to_rgb(hue, 0.82, depth_light)
      alpha = (145 + clamp((point.depth + 1.3) / 2.6, 0.0, 1.0) * 110).round
      [red, green, blue, alpha]
    end

    def hsv_to_rgb(hue, saturation, value)
      sector = (hue % 1.0) * 6.0
      index = sector.floor
      fraction = sector - index
      p = value * (1.0 - saturation)
      q = value * (1.0 - saturation * fraction)
      t = value * (1.0 - saturation * (1.0 - fraction))

      components = case index
                   when 0 then [value, t, p]
                   when 1 then [q, value, p]
                   when 2 then [p, value, t]
                   when 3 then [p, q, value]
                   when 4 then [t, p, value]
                   else [value, p, q]
                   end
      components.map { |component| (component * 255).round }
    end

    def clamp(value, minimum, maximum)
      [[value, minimum].max, maximum].min
    end
  end
end
