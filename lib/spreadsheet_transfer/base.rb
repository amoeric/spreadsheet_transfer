# frozen_string_literal: true

require 'google_drive'
require 'spreadsheet_transfer/configuration'

module SpreadsheetTransfer
  class Error < StandardError; end

  class Base
    class << self
      attr_accessor :configuration

      def configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end
    end

    attr_reader :worksheet

    def initialize(worksheet_title = '')
      @worksheet = session.spreadsheet_by_key(spreadsheet_id).worksheet_by_title(worksheet_title)
    end

    def parse
      return unless in_map?(worksheet)
  
      row_writer if current_map['data_order'] == 'row'
      col_writer if current_map['data_order'] == 'col'
    end
  
    def self.parse_all
      YAML.load_file(SpreadsheetTransfer::Base.configuration.data_map_file).each_key do |k|
        new(k.to_s).parse
      end
    end

    private

    def col_writer
      keys = (current_map['first_key_y']..rows).map{|row| worksheet[row, current_map['first_key_x']]}
  
      array_of_hash =
        (current_map['first_key_x'] + 1..cols).map do |col|
          keys.each_with_object({}).with_index(current_map['first_key_y']) do |(key, result), i|
            next if key == ''
            result[key] = convert(i, col)
          end
        end
  
      file_create(worksheet, array_of_hash, keys, current_map['filename'])
    end
  
    def row_writer
      keys = (current_map['first_key_x']..cols).map{|col| worksheet[current_map['first_key_y'], col].to_sym}
  
      array_of_hash =
        (current_map['first_key_y'] + 1..rows).map do |row|
          keys.each_with_object({}).with_index(current_map['first_key_x']) do |(key, result), i|
            next if key == ''
            result[key] = convert(row, i)
          end
        end
      
      file_create(worksheet, array_of_hash, keys, current_map['filename'])
    end
  
    def export_data_dir
      SpreadsheetTransfer::Base.configuration.export_data_dir
    end
  
    def conf_file
      SpreadsheetTransfer::Base.configuration.conf_file
    end
  
    def spreadsheet_id
      SpreadsheetTransfer::Base.configuration.spreadsheet_id
    end

    def session
      @session ||= GoogleDrive::Session.from_service_account_key(conf_file)
    end
  
    def rows
      worksheet.num_rows
    end
  
    def cols
      worksheet.num_cols
    end
  
    def current_map
      YAML.load_file(SpreadsheetTransfer::Base.configuration.data_map_file)[worksheet.title]
    end
  
    def convert(y, x)
      return worksheet[y, x] if is_date?(y, x) || is_string?(y, x)
  
      convert_to_numeric(y, x)
    end
  
    def convert_to_numeric(y, x)
      return worksheet.numeric_value(y, x).floor if should_floor?(worksheet.numeric_value(y, x))
  
      worksheet.numeric_value(y, x)
    end
  
    def should_floor?(value)
      #except return true -> 10.0, false -> 10.1 or 0.2222
      value % 1 == 0
    end
  
    def is_date?(y, x)
      #1992/01/01、1992/1/1 or 1992-01-01、1992-1-1
      date_regex = %r{
        ^\d{4}[/\-]\d{1,2}[/\-]\d{1,2}
      }x
      
      return false if worksheet[y, x].match(date_regex).nil?
  
      true
    end
  
    def is_string?(y, x)
      worksheet.numeric_value(y, x).nil?
    end
  
    def in_map?(ws)
      YAML.load_file(SpreadsheetTransfer::Base.configuration.data_map_file).keys.include?(ws.title)
    end
  
  end
end
