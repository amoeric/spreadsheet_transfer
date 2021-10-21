# frozen_string_literal: true

require_relative "spreadsheet_transfer/version"
require 'google_drive'
require 'csv'

module SpreadsheetTransfer
  class Error < StandardError; end

  data_dir  = File.expand_path('../data', __dir__)
  conf_file = File.expand_path('../secrets/service_account.json', __dir__)

  spreadsheet_id = '1-bTxpaKKzjQx7kR0TvWpdrE7hOF5B_zM0bkkIVjjAWs'
  session = GoogleDrive::Session.from_service_account_key(conf_file)
  worksheets = session.spreadsheet_by_key(spreadsheet_id).worksheets

  def self.perform
    worksheets.each do |worksheet|
      cols = worksheet.num_cols
      keys = (1..cols).map{|col| worksheet[1, col].to_sym}
    
      array_of_hash =
        (2..worksheet.num_rows).map do |row|
          keys.each_with_object({}).with_index(1) do |(key, result), i|
            result[key] = worksheet[row, i]
          end
        end
    
      CSV.open("#{data_dir}#{worksheet.title}.csv", "wb") do |csv|
        csv << keys
        array_of_hash.each do |hash|
          csv << hash.values
        end
      end
      puts "write #{array_of_hash.size} records to #{worksheet.title}.csv"
    end 
  end
end
