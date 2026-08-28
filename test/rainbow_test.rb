# frozen_string_literal: true

require_relative "test_helper"

class RainbowTest < Minitest::Test
  def test_primary_hues
    assert_equal [255, 0, 0], DotMan::Rainbow.hsv_to_rgb(0.0, 1.0, 1.0)
    assert_equal [0, 255, 0], DotMan::Rainbow.hsv_to_rgb(1.0 / 3.0, 1.0, 1.0)
    assert_equal [0, 0, 255], DotMan::Rainbow.hsv_to_rgb(2.0 / 3.0, 1.0, 1.0)
  end

  def test_animation_changes_a_points_color
    point = DotMan::ProjectedPoint.new(depth: 0.0, phase: 0.0, world_y: 0.0)

    refute_equal DotMan::Rainbow.color(point, 0.0), DotMan::Rainbow.color(point, 1.0)
  end
end
