# frozen_string_literal: true

module SpreadsheetTransfer
  class ColumnSheet < RowSheet
    def keys
      return raw_rows[@datamap['first_key_x']-1] unless has_replace_keys?

      raw_rows[@datamap['first_key_x']-1].each { |kk| replace_keys.each { |k, v| kk.gsub!(k, v) } }
    end

    def rows
      return raw_rows[@datamap['first_key_x']..-1] unless has_replace_values?

      raw_rows[@datamap['first_key_x']..-1].map do |row|
        row.map do |r|
          if r.empty?
            r
          else
            replace_values.include?(r.gsub(' ','')) ? replace_values[r.gsub(' ','')] : r
          end
        end
      end
    end

    private
    def raw_rows
      @raw_rows ||= @worksheet.rows.transpose
    end
  end
end
