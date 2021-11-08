# frozen_string_literal: true

module SpreadsheetTransfer
  class RowSheet
    def initialize(worksheet, datamap)
      @worksheet = worksheet
      @datamap = datamap
    end

    def title
      @worksheet.title
    end

    def keys
      raw_rows[@datamap['first_key_y']-1]
    end

    def rows
      raw_rows[@datamap['first_key_y']..-1]
    end

    def items
      @items ||= rows.map { |row| keys.zip(row).to_h }
    end

    private
    def raw_rows
      @raw_rows ||= @worksheet.rows
    end
  end
end