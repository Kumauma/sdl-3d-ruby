# frozen_string_literal: true

module DotMan
  Point3 = Struct.new(:x, :y, :z, :phase, keyword_init: true)

  class Mannequin
    GOLDEN_FRACTION = 0.618_033_988_75

    def self.points
      @points ||= new.build.freeze
    end

    def initialize
      @points = []
    end

    def build
      add_head
      add_neck
      add_torso
      add_pelvis
      add_arms
      add_legs
      add_orientation_details

      @points.each_with_index do |point, index|
        point.phase = (index * GOLDEN_FRACTION) % 1.0
        point.freeze
      end
    end

    private

    def add_head
      ellipsoid([0.0, 2.1, 0.0], [0.42, 0.55, 0.40], latitude_rings: 5, ring_points: 11)
    end

    def add_neck
      tube_between([-0.0, 1.48, 0.0], [0.0, 1.67, 0.0], 0.18, 0.20,
                   length_steps: 2, ring_points: 7)
    end

    def add_torso
      rings = [
        [1.48, 0.48, 0.25],
        [1.28, 0.70, 0.34],
        [1.02, 0.67, 0.36],
        [0.75, 0.60, 0.34],
        [0.48, 0.52, 0.30],
        [0.22, 0.45, 0.27],
        [0.02, 0.43, 0.26]
      ]

      rings.each_with_index do |(y, width, depth), ring_index|
        elliptical_ring([0.0, y, 0.0], width, depth, 11, offset: ring_index.odd? ? 0.5 : 0.0)
      end
    end

    def add_pelvis
      ellipsoid([0.0, -0.18, 0.0], [0.49, 0.36, 0.31], latitude_rings: 3, ring_points: 10)
    end

    def add_arms
      left_shoulder = [-0.63, 1.25, 0.0]
      left_elbow = [-0.96, 0.55, 0.10]
      left_wrist = [-1.03, -0.12, 0.20]
      right_shoulder = [0.63, 1.25, 0.0]
      right_elbow = [0.94, 0.52, -0.12]
      right_wrist = [1.01, -0.15, -0.20]

      tube_between(left_shoulder, left_elbow, 0.18, 0.145, length_steps: 4, ring_points: 6)
      tube_between(left_elbow, left_wrist, 0.15, 0.095, length_steps: 4, ring_points: 6)
      ellipsoid(left_wrist, [0.13, 0.19, 0.11], latitude_rings: 2, ring_points: 6)

      tube_between(right_shoulder, right_elbow, 0.18, 0.145, length_steps: 4, ring_points: 6)
      tube_between(right_elbow, right_wrist, 0.15, 0.095, length_steps: 4, ring_points: 6)
      ellipsoid(right_wrist, [0.13, 0.19, 0.11], latitude_rings: 2, ring_points: 6)
    end

    def add_legs
      left_hip = [-0.28, -0.32, 0.0]
      left_knee = [-0.39, -1.25, 0.08]
      left_ankle = [-0.40, -2.18, 0.08]
      right_hip = [0.28, -0.32, 0.0]
      right_knee = [0.39, -1.25, -0.07]
      right_ankle = [0.40, -2.18, -0.07]

      tube_between(left_hip, left_knee, 0.25, 0.19, length_steps: 5, ring_points: 7)
      tube_between(left_knee, left_ankle, 0.19, 0.115, length_steps: 5, ring_points: 7)
      ellipsoid([-0.40, -2.32, 0.19], [0.20, 0.13, 0.36], latitude_rings: 2, ring_points: 7)

      tube_between(right_hip, right_knee, 0.25, 0.19, length_steps: 5, ring_points: 7)
      tube_between(right_knee, right_ankle, 0.19, 0.115, length_steps: 5, ring_points: 7)
      ellipsoid([0.40, -2.32, 0.04], [0.20, 0.13, 0.36], latitude_rings: 2, ring_points: 7)
    end

    def add_orientation_details
      # A small nose and two ear rings make front/back and profile views legible.
      ellipsoid([0.0, 2.14, 0.43], [0.10, 0.10, 0.14], latitude_rings: 1, ring_points: 5)
      elliptical_ring([-0.43, 2.12, 0.0], 0.05, 0.10, 5)
      elliptical_ring([0.43, 2.12, 0.0], 0.05, 0.10, 5)
    end

    def ellipsoid(center, radii, latitude_rings:, ring_points:)
      cx, cy, cz = center
      rx, ry, rz = radii

      @points << point(cx, cy + ry, cz)
      1.upto(latitude_rings) do |latitude_index|
        latitude = Math::PI * latitude_index / (latitude_rings + 1) - Math::PI / 2.0
        ring_radius = Math.cos(latitude)
        y = cy + Math.sin(latitude) * ry

        ring_points.times do |longitude_index|
          longitude = Math::PI * 2.0 * longitude_index / ring_points
          @points << point(
            cx + Math.cos(longitude) * rx * ring_radius,
            y,
            cz + Math.sin(longitude) * rz * ring_radius
          )
        end
      end
      @points << point(cx, cy - ry, cz)
    end

    def elliptical_ring(center, radius_x, radius_z, count, offset: 0.0)
      cx, cy, cz = center
      count.times do |index|
        angle = Math::PI * 2.0 * (index + offset) / count
        @points << point(cx + Math.cos(angle) * radius_x, cy, cz + Math.sin(angle) * radius_z)
      end
    end

    def tube_between(start_point, end_point, start_radius, end_radius, length_steps:, ring_points:)
      direction = subtract(end_point, start_point)
      axis = normalize(direction)
      reference = axis[1].abs < 0.9 ? [0.0, 1.0, 0.0] : [1.0, 0.0, 0.0]
      basis_u = normalize(cross(axis, reference))
      basis_v = cross(axis, basis_u)

      0.upto(length_steps) do |step|
        t = step.to_f / length_steps
        center = add(start_point, scale(direction, t))
        radius = start_radius + (end_radius - start_radius) * t

        ring_points.times do |ring_index|
          angle = Math::PI * 2.0 * (ring_index + (step.odd? ? 0.5 : 0.0)) / ring_points
          offset = add(scale(basis_u, Math.cos(angle) * radius),
                       scale(basis_v, Math.sin(angle) * radius))
          coordinates = add(center, offset)
          @points << point(*coordinates)
        end
      end
    end

    def point(x, y, z)
      Point3.new(x: x, y: y, z: z, phase: 0.0)
    end

    def add(a, b)
      [a[0] + b[0], a[1] + b[1], a[2] + b[2]]
    end

    def subtract(a, b)
      [a[0] - b[0], a[1] - b[1], a[2] - b[2]]
    end

    def scale(vector, amount)
      vector.map { |component| component * amount }
    end

    def cross(a, b)
      [
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0]
      ]
    end

    def normalize(vector)
      length = Math.sqrt(vector.sum { |component| component * component })
      vector.map { |component| component / length }
    end
  end
end
