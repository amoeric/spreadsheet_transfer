# frozen_string_literal: true

require 'spreadsheet_transfer/exporter/base'

module SpreadsheetTransfer
  module Exporter
    class JSON < Base
      def export!
        File.open("#{@dir}/#{@filename}", 'w') do |f|
          f.write(@sheet.items.to_json)
        end

        puts "write #{@sheet.items.size} records to #{@dir}/#{@filename}"
      end
    end
  end
end
