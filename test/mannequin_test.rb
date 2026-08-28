# frozen_string_literal: true

require_relative "test_helper"

class MannequinTest < Minitest::Test
  def test_builds_a_detailed_but_lightweight_point_cloud
    points = DotMan::Mannequin.points

    assert_operator points.length, :>=, 350
    assert_operator points.length, :<=, 600
    assert_operator points.map(&:x).min, :<, -1.0
    assert_operator points.map(&:x).max, :>, 1.0
    assert_operator points.map(&:y).min, :<, -2.4
    assert_operator points.map(&:y).max, :>, 2.5
    assert points.all?(&:frozen?)
  end
end
