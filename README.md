# SpreadsheetTransfer


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spreadsheet_transfer', git: 'https://github.com/amoeric/spreadsheet_transfer.git'
```

And then execute:

    $ bundle install


## Usage

### 1. 設定 service_account.json

所申請的 google spreadsheet api json 檔

### 2. 設定 spread_sheet.yml

#### 資料架構
```
company:
  filename: 'company_base'
  first_key_x: 1
  first_key_y: 2
  data_order: 'row'
```
#### 架構說明
company：  分頁名稱
filename： 產出的檔案名稱
first_key_x、first_key_y： 第一個 key 的 x、y 位置

```
# 如果在 A2
  first_key_x: 1
  first_key_y: 2
```
data_order: 每筆資料排序，分為 ``'col'`` 或 `'row'`

### 3. 建立 spreadsheet_transfer.rb 


```ruby
#config/initializers/spreadsheet_transfer.rb

SpreadsheetTransfer::Base.configure do |c|
  c.export_data_dir = Rails.root.join('data')
  c.conf_file = Rails.root.join('secrets/service_account.json')
  c.data_map_file = Rails.root.join('spread_sheet.yml')
  c.spreadsheet_id = '1fHANc0l4ndQsdadasW5sBsteeI8'
end
```

### 4. 使用方式
```ruby
# rails console
# 轉換所有
SpreadsheetTransfer::Csv.parse_all
# 特定分頁，company 為分頁名稱
SpreadsheetTransfer::Csv.new('company').parse
```
