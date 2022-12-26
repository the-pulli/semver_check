# frozen_string_literal: true

require "test_helper"

# Test CompareClass
class TestCompare < Minitest::Test
  include SemverCheck

  def setup
    @semver = Compare.new("1.2.3")
  end

  def test_two_equal_instances
    assert_equal 0, Compare.new("1.2.3") <=> @semver
  end

  def test_two_different_instances_with_self_greater_than_other
    assert_equal 1, Compare.new("1.2.4") <=> @semver
  end

  def test_two_different_instances_with_self_less_than_other
    assert_equal(-1, Compare.new("0.1.5") <=> @semver)
  end

  def test_it_returns_nil_if_comparison_class_is_not_semver_check
    assert_nil @semver <=> 1
  end

  def test_the_greater_than_operator
    assert_equal true, Compare.new("3.1.7") > @semver
    assert_equal false, Compare.new("1.2.3") > @semver
    assert_equal false, Compare.new("1.2.2") > @semver
    assert_equal true, Compare.new("1.2.3") > Compare.new("1.2.3-alpha")
    assert_equal true, Compare.new("1.2.3-beta") > Compare.new("1.2.3-alpha")
    assert_equal true, Compare.new("1.2.3-beta.2") > Compare.new("1.2.3-alpha.2")
  end

  def test_the_greater_or_equal_than_operator
    assert_equal true, Compare.new("1.2.3") >= @semver
    assert_equal true, Compare.new("1.2.4") >= @semver
    assert_equal false, Compare.new("1.2.2") >= @semver
    assert_equal false, Compare.new("0.2.4") >= @semver
  end

  def test_the_less_than_operator
    assert_equal true, Compare.new("0.1.5") < @semver
    assert_equal false, Compare.new("1.2.3") < @semver
    assert_equal false, Compare.new("1.2.4") < @semver
    assert_equal true, Compare.new("1.2.3-alpha.1") < Compare.new("1.2.3-alpha.2")
    assert_equal true, Compare.new("1.2.3-alpha.1") < Compare.new("1.2.3-beta.2")
    assert_equal false, Compare.new("1.2.3-alpha.2") < Compare.new("1.2.3-alpha.2")
    assert_equal false, Compare.new("1.2.3-alpha.3") < Compare.new("1.2.3-alpha.2")
    assert_equal true, Compare.new("1.2.3-alpha.3") < Compare.new("2.2.3-alpha.2")
    assert_equal true, Compare.new("1.2.3-alpha.3") < Compare.new("1.2.3")
  end

  def test_the_less_or_equal_than_operator
    assert_equal true, Compare.new("1.2.3") <= @semver
    assert_equal true, Compare.new("1.2.2") <= @semver
    assert_equal false, Compare.new("1.2.4") <= @semver
    assert_equal false, Compare.new("2.2.3") <= @semver
  end

  def test_the_equal_operator
    assert_equal true, Compare.new("1.2.3") == @semver
    assert_equal false, Compare.new("1.2.2") == @semver
    assert_equal true, Compare.new("1.2.2-alpha.1") == Compare.new("1.2.2-alpha.1")
    assert_equal false, Compare.new("1.2.2-alpha.2") == Compare.new("1.2.2-alpha.1")
  end

  def test_the_not_equal_operator
    assert_equal true, Compare.new("1.2.4") != @semver
    assert_equal false, Compare.new("1.2.3") != @semver
    assert_equal true, Compare.new("1.2.2-alpha.2") != Compare.new("1.2.2-alpha.1")
    assert_equal true, Compare.new("1.2.2-alpha.2") != Compare.new("1.2.2+build.1")
    assert_equal false, Compare.new("1.2.2+build.1") != Compare.new("1.2.2+build.1")
  end

  def test_the_edge_case_with_buildmetadata
    assert_equal true , @semver > Compare.new("1.2.3+build")
    assert_equal true , @semver >= Compare.new("1.2.3+build")
    assert_equal true , Compare.new("1.2.3+build") < @semver
    assert_equal true , Compare.new("1.2.3+build") <= @semver
    assert_equal true , Compare.new("1.2.3+build") == Compare.new("1.2.3+build")
    assert_equal true , Compare.new("1.2.3+build.somemoreinfo") == Compare.new("1.2.3+build")
  end

  def test_remaining_comparable_methods
    assert_equal true, @semver.between?(Compare.new("1.2.2"), Compare.new("1.2.4"))
    assert_equal [Compare.new("1.2.2"), @semver, Compare.new("1.2.4")], [@semver, Compare.new("1.2.4"), Compare.new("1.2.2")].sort
  end

  def test_the_version_getter_without_prerelease_and_build
    assert_equal({ semver: "1.2.3",
                   major: 1,
                   minor: 2,
                   patch: 3,
                   prerelease: nil,
                   buildmetadata: nil }, @semver.version)
  end

  def test_the_version_getter_with_full_semver
    assert_equal({ semver: "1.2.3-beta.1+build.123",
                   major: 1,
                   minor: 2,
                   patch: 3,
                   prerelease: "beta.1",
                   buildmetadata: "build.123" }, Compare.new("1.2.3-beta.1+build.123").version)
  end

  def test_if_semver_regex_is_valid_with_their_test_strings
    File.read(File.join(__dir__, "fixtures", "valid.txt")).each_line(chomp: true) do |v|
      assert_equal v, Compare.new(v).to_s
    end
  end

  def test_the_to_s_function
    assert_equal "1.2.3-beta.1+build.123", Compare.new("1.2.3-beta.1+build.123").to_s
    assert_equal "1.2.3+build.123", Compare.new("1.2.3+build.123").to_s
    assert_equal "1.2.3-beta.1", Compare.new("1.2.3-beta.1").to_s
    assert_equal "1.2.3-beta", Compare.new("1.2.3-beta").to_s
    assert_equal "1.2.3", Compare.new("1.2.3").to_s
  end

  def test_raises_argument_error_with_invalid_semver_versions_including_the_official_test_strings
    File.read(File.join(__dir__, "fixtures", "invalid.txt")).each_line(chomp: true) do |v|
      e = assert_raises(ArgumentError) { Compare.new(v) }
      assert_equal "No proper Semantic Versioning given", e.message
    end
  end
end
