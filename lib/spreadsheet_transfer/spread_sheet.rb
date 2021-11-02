# frozen_string_literal: true

require 'google_drive'
require 'spreadsheet_transfer/row_sheet'
require 'spreadsheet_transfer/column_sheet'
require 'spreadsheet_transfer/exporter/csv'
require 'spreadsheet_transfer/exporter/json'

module SpreadsheetTransfer
  class SpreadSheet

    attr_reader :datamap

    def initialize(spreadsheet_id:, datamap_file:, conf_file:)
      @datamap ||= YAML.load_file(File.expand_path(datamap_file, __dir__))
      @conf_file ||= File.expand_path(conf_file, __dir__)
      @spreadsheet = session.spreadsheet_by_key(spreadsheet_id)
    end

    def name
      @name ||= @spreadsheet.title
    end

    def sheets
      @sheets ||= @spreadsheet.worksheets
    end

    def data
      sheets.map do |s|
        next unless datamap.keys.include?(s.title)

	{
	  worksheet: s.title,
	  items: 
	    datamap[s.title]['data_order'] == 'row' ? 
	    SpreadsheetTransfer::RowSheet.new(s, datamap[s.title]).items :
	    SpreadsheetTransfer::ColumnSheet.new(s, datamap[s.title]).items
        }
      end.compact
    end

    def export_all_to_csv
      sheets.each do |s|
        next unless datamap.keys.include?(s.title)

	data = datamap[s.title]['data_order'] == 'row' ?
	       SpreadsheetTransfer::RowSheet.new(s, datamap[s.title]) :
	       SpreadsheetTransfer::ColumnSheet.new(s, datamap[s.title])

	SpreadsheetTransfer::Exporter::CSV.new("#{datamap[s.title]['filename']}.csv", data, datamap[s.title]['export_dir']).export!
      end
    end

    def export_all_to_json
      sheets.each do |s|
        next unless datamap.keys.include?(s.title)

	data = datamap[s.title]['data_order'] == 'row' ?
	       SpreadsheetTransfer::RowSheet.new(s, datamap[s.title]) :
	       SpreadsheetTransfer::ColumnSheet.new(s, datamap[s.title])

	SpreadsheetTransfer::Exporter::JSON.new("#{datamap[s.title]['filename']}.json", data, datamap[s.title]['export_dir']).export!
      end
    end

    private
    def session
      @session ||= GoogleDrive::Session.from_service_account_key(@conf_file)
    end
  end
end
