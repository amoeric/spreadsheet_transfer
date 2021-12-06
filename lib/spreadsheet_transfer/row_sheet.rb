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
      return raw_rows[@datamap['first_key_y']-1] unless has_replace_keys?

      raw_rows[@datamap['first_key_y']-1].each { |kk| replace_keys.each { |k, v| kk.gsub!(k, v) if kk == k } }
    end

    def rows
      return raw_rows[@datamap['first_key_y']..-1] unless has_replace_values?

      raw_rows[@datamap['first_key_y']..-1].map do |row|
        row.map do |r|
          if r.empty?
            r
          else
            replace_values.include?(r.gsub(' ','')) ? replace_values[r.gsub(' ','')] : r
          end
        end
      end
    end

    def items
      @items ||= rows.map { |row| keys.zip(row).to_h }
    end

    def replace_keys
      return unless has_replace_keys?

      @datamap['replace_keys']
    end

    def replace_values
      return unless has_replace_values?

      @datamap['replace_values']
    end

    private
    def raw_rows
      @raw_rows ||= @worksheet.rows
    end

    def has_replace_keys?
      !@datamap['replace_keys'].nil?
    end

    def has_replace_values?
      !@datamap['replace_values'].nil?
    end
  end
end
