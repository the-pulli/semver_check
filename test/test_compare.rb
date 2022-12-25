# frozen_string_literal: true

require "test_helper"

# Test CompareClass
class CompareTest < Minitest::Test
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
    %w[
      0.0.4
      1.2.3
      10.20.30
      1.1.2-prerelease+meta
      1.1.2+meta
      1.1.2+meta-valid
      1.0.0-alpha
      1.0.0-beta
      1.0.0-alpha.beta
      1.0.0-alpha.beta.1
      1.0.0-alpha.1
      1.0.0-alpha0.valid
      1.0.0-alpha.0valid
      1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay
      1.0.0-rc.1+build.1
      2.0.0-rc.1+build.123
      1.2.3-beta
      10.2.3-DEV-SNAPSHOT
      1.2.3-SNAPSHOT-123
      1.0.0
      2.0.0
      1.1.7
      2.0.0+build.1848
      2.0.1-alpha.1227
      1.0.0-alpha+beta
      1.2.3----RC-SNAPSHOT.12.9.1--.12+788
      1.2.3----R-S.12.9.1--.12+meta
      1.2.3----RC-SNAPSHOT.12.9.1--.12
      1.0.0+0.build.1-rc.10000aaa-kk-0.1
      99999999999999999999999.999999999999999999.99999999999999999
      1.0.0-0A.is.legal
    ].each do |v|
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

  def test_raises_argument_error_with_invalid_semver_version
    %w[
      1.2.3.2
      1.2.3invalidprerelease
      1.2.3-prerelease=invalidbuild
      1.2.3-prerelease_1
      00.2.3-prerelease
      0.00.3-prerelease
      0.0.00-prerelease
      1
      1.2
      1.2.3-0123
      1.2.3-0123.0123
      1.1.2+.123
      +invalid
      -invalid
      -invalid+invalid
      -invalid.01
      alpha
      alpha.beta
      alpha.beta.1
      alpha.1
      alpha+beta
      alpha_beta
      alpha.
      alpha..
      beta
      1.0.0-alpha_beta
      -alpha.
      1.0.0-alpha..
      1.0.0-alpha..1
      1.0.0-alpha...1
      1.0.0-alpha....1
      1.0.0-alpha.....1
      1.0.0-alpha......1
      1.0.0-alpha.......1
      01.1.1
      1.01.1
      1.1.01
      1.2
      1.2.3.DEV
      1.2-SNAPSHOT
      1.2.31.2.3----RC-SNAPSHOT.12.09.1--..12+788
      1.2-RC-SNAPSHOT
      -1.0.3-gamma+b7718
      +justmeta
      9.8.7+meta+meta
      9.8.7-whatever+meta+meta
      99999999999999999999999.999999999999999999.99999999999999999----RC-SNAPSHOT.12.09.1--------------------------------..12
    ].each do |v|
      e = assert_raises(ArgumentError) { Compare.new(v) }
      assert_equal "No proper Semantic Versioning given", e.message
    end
  end
end
