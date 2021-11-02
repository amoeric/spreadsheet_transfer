# frozen_string_literal: true

module SpreadsheetTransfer
  module Exporter
    class Base
      def initialize(filename, sheet, dir)
        @filename = filename
        @sheet = sheet
        @dir = dir
      end

      def export!
        raise NotImplementedError
      end
    end
  end
end
