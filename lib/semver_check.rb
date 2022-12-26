# frozen_string_literal: true

require_relative "semver_check/version"

# SemverCheck module
module SemverCheck
  # Class to compare SemVer strings
  class Compare
    include Comparable

    SEMVER_PATTERN = /\A
                    (?<semver>
                      (?<major>0|[1-9]\d*)
                      \.
                      (?<minor>0|[1-9]\d*)
                      \.
                      (?<patch>0|[1-9]\d*)
                      (?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)
                        (?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)
                      )?
                      (?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?
                    )
                  \Z/x

    MAPPING_TABLE = [
      ["n", 1],
      ["sn", 1],
      ["ssn", 1],
      ["o", -1],
      ["so", -1],
      ["sso", -1],
      ["sss", 0]
    ].freeze

    VERSION_PARTS = %i[major minor patch].freeze

    attr_reader :version

    def initialize(version)
      @version = prepare_version(version)
    end

    def <=>(other)
      return nil unless other.is_a? Compare

      comparison(other)
    end

    def !=(other)
      [-1, 1].include?(self.<=>(other))
    end

    def to_s
      @version[:semver]
    end

    private

    def comparison(other)
      comparison = VERSION_PARTS.map do |part|
        if @version[part] == other.version[part]
          "s"
        elsif @version[part] > other.version[part]
          "n"
        else
          "o"
        end
      end.join
      buildmetadata_sort(other, prerelease_sort(other, comparison))
    end

    def prerelease_sort(other, comparison)
      v_pre = @version[:prerelease].nil? ? "" : @version[:prerelease]
      o_pre = other.version[:prerelease].nil? ? "" : other.version[:prerelease]
      version_compare = match(comparison)
      if version_compare.zero?
        sorted = [v_pre, o_pre].sort.reverse
        if (v_pre == sorted.last && v_pre != o_pre && v_pre != "") || (v_pre != "" && o_pre == "")
          -1
        elsif (v_pre == sorted.first && v_pre != o_pre) || (v_pre == "" && o_pre != "")
          1
        else
          0
        end
      else
        version_compare
      end
    end

    def buildmetadata_sort(other, comparison)
      v_build = @version[:buildmetadata]
      o_build = other.version[:buildmetadata]
      if comparison.zero?
        if v_build.nil? && !o_build.nil?
          1
        elsif !v_build.nil? && o_build.nil?
          -1
        else
          0
        end
      else
        comparison
      end
    end

    def match(comparison)
      MAPPING_TABLE.find do |m|
        comparison.start_with?(m.first)
      end.last
    end

    def prepare_version(version)
      version = version.match(SEMVER_PATTERN)
      raise ArgumentError, "No proper Semantic Versioning given" if version.nil?

      version = version.named_captures.transform_keys(&:to_sym)
      # convert major, minor and patch to int
      VERSION_PARTS.each { |part| version[part] = version[part].to_i }
      version
    end
  end
end
