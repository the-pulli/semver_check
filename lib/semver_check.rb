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

    INT_RESULT = {
      n: 1,
      o: -1,
      s: 0
    }.freeze

    MAPPING_TABLE = [
      %w[n[nso]{2} n],
      %w[sn[nso]{1} n],
      %w[ssn n],
      %w[o[nso]{2} o],
      %w[so[nso]{1} o],
      %w[sso o],
      %w[sss s]
    ].freeze

    ORDER = %i[major minor patch prerelease].freeze

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
      comparison = ORDER.take(3).map do |part|
        if @version[part] == other.version[part]
          "s"
        elsif @version[part] > other.version[part]
          "n"
        else
          "o"
        end
      end.join
      prerelease_sort(other, comparison)
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

    def match(comparison)
      result = MAPPING_TABLE.map do |m|
        m[1] if comparison.match?(/\A#{m[0]}\Z/)
      end.compact

      raise "Too many results" if result.length > 1

      INT_RESULT[result.first.to_sym]
    end

    def prepare_version(version)
      version = version.match(SEMVER_PATTERN)
      raise ArgumentError, "No proper Semantic Versioning given" if version.nil?

      version = version.named_captures.transform_keys(&:to_sym)
      # convert major, minor and patch to int
      ORDER.take(3).each { |part| version[part] = version[part].to_i }
      version
    end
  end
end
