# frozen_string_literal: true

require 'google_drive'

module SpreadsheetTransfer
  class Error < StandardError; end

  attr_reader :worksheets

  class Base
    def initialize(spreadsheet_id)
      session = GoogleDrive::Session.from_service_account_key(conf_file)
      @worksheets = session.spreadsheet_by_key(spreadsheet_id).worksheets
    end

    def perform
      worksheets.each do |worksheet|
        cols = worksheet.num_cols
        keys = (1..cols).map{|col| worksheet[1, col].to_sym}
        array_of_hash =
          (2..worksheet.num_rows).map do |row|
            keys.each_with_object({}).with_index(1) do |(key, result), i|
              result[key] = worksheet[row, i]
            end
          end
  
        file_create(array_of_hash, keys)
        puts "write #{array_of_hash.size} records to #{worksheet.title}.csv"
      end 
    end

    private

    def data_dir
      @data_dir ||= File.expand_path('../data', __dir__)
    end

    def conf_file
      @conf_file ||= File.expand_path('../secrets/service_account.json', __dir__)
    end
  end
end
