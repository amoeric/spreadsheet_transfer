# frozen_string_literal: true

module SpreadsheetTransfer
  class Configuration
    attr_accessor :export_data_dir, :conf_file, :data_map_file, :spreadsheet_id

    def initialize
      @export_data_dir ||= File.expand_path('../../data', __dir__)
      @conf_file ||= File.expand_path('../../secrets/service_account.json', __dir__)
      @data_map_file ||= File.expand_path('spread_sheet.yml', __dir__)
      @spreadsheet_id ||= ''
    end
  end
end