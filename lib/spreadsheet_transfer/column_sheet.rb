# frozen_string_literal: true

module SpreadsheetTransfer
  class ColumnSheet < RowSheet
    def keys
      raw_rows[@datamap['first_key_x']-1]
    end

    def rows
      raw_rows[@datamap['first_key_x']..-1]
    end

    private
    def raw_rows
      @raw_rows ||= @worksheet.rows.transpose
    end
  end
end