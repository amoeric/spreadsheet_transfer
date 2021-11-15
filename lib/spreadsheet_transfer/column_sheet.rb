# frozen_string_literal: true

module SpreadsheetTransfer
  class ColumnSheet < RowSheet
    def keys
      return raw_rows[@datamap['first_key_x']-1] unless has_replace_keys?

      raw_rows[@datamap['first_key_x']-1].each { |kk| replace_keys.each { |k, v| kk.gsub!(k, v) } }
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
