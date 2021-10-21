# frozen_string_literal: true
require './spreadsheet_transfer/base'
require 'csv'

module SpreadsheetTransfer
  class CSV < Base
    def file_create(array_of_hash, keys)
      CSV.open("#{data_dir}/#{worksheet.title}.csv", "wb") do |csv|
        csv << keys
        array_of_hash.each do |hash|
          csv << hash.values
        end
      end    
    end
  end
end
