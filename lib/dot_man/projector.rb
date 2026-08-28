# frozen_string_literal: true

module DotMan
  ProjectedPoint = Struct.new(:x, :y, :depth, :size, :phase, :world_y, keyword_init: true)

  class Projector
    attr_reader :width, :height

    def initialize(width:, height:, camera_distance: 7.5, focal_length: 690.0)
      @width = width
      @height = height
      @camera_distance = camera_distance
      @focal_length = focal_length
    end

    def project(points, angle)
      cosine = Math.cos(angle)
      sine = Math.sin(angle)

      points.map do |point|
        rotated_x = point.x * cosine + point.z * sine
        rotated_z = -point.x * sine + point.z * cosine
        perspective = @focal_length / (@camera_distance - rotated_z)

        ProjectedPoint.new(
          x: @width / 2.0 + rotated_x * perspective,
          y: @height / 2.0 - 4.0 - point.y * perspective,
          depth: rotated_z,
          size: [[(perspective / 25.0).round, 3].max, 7].min,
          phase: point.phase,
          world_y: point.y
        )
      end.sort_by(&:depth)
    end
  end
end
