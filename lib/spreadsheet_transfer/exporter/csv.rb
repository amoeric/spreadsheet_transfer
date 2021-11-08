# frozen_string_literal: true

require 'csv'
require 'spreadsheet_transfer/exporter/base'

module SpreadsheetTransfer
  module Exporter
    class CSV < Base
      def export!
        p 'dir'
        p @dir
        ::CSV.open("#{@dir}/#{@filename}", 'w') do |csv|
          csv << @sheet.keys
          @sheet.rows.each { |row| csv << row }
        end

        puts "write #{@sheet.items.size} records to #{@dir}/#{@filename}"
      end
    end
  end
end
