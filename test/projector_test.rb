# frozen_string_literal: true

require_relative "test_helper"

class ProjectorTest < Minitest::Test
  Point = DotMan::Point3

  def setup
    @projector = DotMan::Projector.new(width: 800, height: 600)
  end

  def test_projects_origin_to_visual_center
    projected = @projector.project([Point.new(x: 0.0, y: 0.0, z: 0.0, phase: 0.0)], 0.0).first

    assert_in_delta 400.0, projected.x, 1e-10
    assert_in_delta 296.0, projected.y, 1e-10
  end

  def test_quarter_turn_rotates_x_axis_into_depth
    point = Point.new(x: 1.0, y: 0.0, z: 0.0, phase: 0.0)
    projected = @projector.project([point], Math::PI / 2.0).first

    assert_in_delta 400.0, projected.x, 1e-10
    assert_in_delta(-1.0, projected.depth, 1e-10)
  end

  def test_near_points_are_sorted_last_and_appear_no_smaller
    far = Point.new(x: 0.0, y: 0.0, z: -1.0, phase: 0.0)
    near = Point.new(x: 0.0, y: 0.0, z: 1.0, phase: 0.0)
    projected = @projector.project([near, far], 0.0)

    assert_equal [-1.0, 1.0], projected.map(&:depth)
    assert_operator projected.last.size, :>=, projected.first.size
  end
end
