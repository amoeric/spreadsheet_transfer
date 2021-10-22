# frozen_string_literal: true

require 'csv'
require 'spreadsheet_transfer/base'

module SpreadsheetTransfer
  class Csv < Base
    private

    def file_create(worksheet, array_of_hash, keys, filename)
      ::CSV.open("#{export_data_dir}/#{filename}.csv", "wb") do |csv|
        csv << keys
        array_of_hash.each do |hash|
          csv << hash.values
        end
      end

      puts "write #{array_of_hash.size} records to #{filename}.csv" 
    end
  end
end
