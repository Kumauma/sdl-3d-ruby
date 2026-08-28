# frozen_string_literal: true

require_relative "test_helper"

class AnimationTest < Minitest::Test
  def test_starts_paused_and_only_advances_while_rotating
    animation = DotMan::Animation.new(seconds_per_turn: 4.0)

    refute animation.rotating?
    assert_equal 0.0, animation.update(1.0)

    animation.toggle
    assert animation.rotating?
    assert_in_delta Math::PI / 2.0, animation.update(1.0), 1e-10

    animation.toggle
    assert_in_delta Math::PI / 2.0, animation.update(1.0), 1e-10
  end

  def test_wraps_after_a_full_turn
    animation = DotMan::Animation.new(seconds_per_turn: 4.0)
    animation.toggle

    assert_in_delta 0.0, animation.update(4.0), 1e-10
  end
end
