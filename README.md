# SpreadsheetTransfer


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spreadsheet_transfer', git: 'https://github.com/amoeric/spreadsheet_transfer.git'
```

And then execute:

    $ bundle install


## 試算表格式


(O) 所支援格式

```
#row
|流水號|姓名|地址|
|id|name|address|
|1|eric|taiwan|

or

|id|name|address|
|1|eric|taiwan|

#col
|流水號|id|1|
|姓名|name|eric|
|地址|address|taiwan|

or

|id|1|
|name|eric|
|address|taiwan|
```

(Ｘ) 並不會過濾無意義欄位

```
# 欄位中的排序號
|id|1|name|address|
|1 |2|eric|taiwan|

#下方註解
|id   |name |address|
|1    |eric |taiwan|
|''   |''   |''|
|'註解'|'註解'|''|
```




## Usage

### 1. 設定 service_account.json

申請的 google spreadsheet api json 檔

### 2. 設定 datamap.yml

#### 資料架構

```
company:
  filename: 'company_base'
  first_key_x: 1
  first_key_y: 2
  data_order: 'row'
  export_dir: 'data'
```

#### 架構說明
company：  分頁名稱  
filename： 產出的檔案名稱  
first_key_x、first_key_y： 第一個 key 的 x、y 位置  
  
ex: A2 cell
- first_key_x: 1
- first_key_y: 2


data_order: 每筆資料排序，分為 ``'col'`` 或 `'row'`  
export_dir： 匯出路徑

### 3. 使用方式

分成 spreadsheet 、 sheet 、 exporter

```ruby
spreadsheet = SpreadsheetTransfer::SpreadSheet.new(spreadsheet_id: '12234235454WSA8Bqweqe122', datamap_file: 'path/datamap.yml', conf_file: 'path/service_account.json')

spreadsheet.name
=> '未命名的試算表'

spreadsheet.data
=> [
{:worksheet=>"company", :items=>[{"id"=>"1", "name"=>"apple", "country"=>"usa"}, {"id"=>"2", "name"=>"samsung", "country"=>"korea"}]},
{:worksheet=>"col_company", :items=>[{"id"=>"1", "item_id"=>"1", "name"=>"car"}, {"id"=>"2", "item_id"=>"1", "name"=>"bicycle"}]}
]

spreadsheet.sheets
=> [
#<GoogleDrive::Worksheet spreadsheet_id="12234235454WSA8Bqweqe122", gid="7578", title="company">,
#<GoogleDrive::Worksheet spreadsheet_id="12234235454WSA8Bqweqe122", gid="0", title="col_company">
]


sheet = spreadsheet.sheets.find {|s| s.title == 'col_company'}
SpreadsheetTransfer::ColumnSheet.new(sheet, spreadsheet.datamap[sheet.title]).name
=> 'col_company'
SpreadsheetTransfer::ColumnSheet.new(sheet, spreadsheet.datamap[sheet.title]).keys
=> ["id", "item_id", "name"]
SpreadsheetTransfer::ColumnSheet.new(sheet, spreadsheet.datamap[sheet.title]).rows
=> [["1", "1", "car"], ["2", "1", "bicycle"]]
SpreadsheetTransfer::ColumnSheet.new(sheet, spreadsheet.datamap[sheet.title]).items
=> [
{"id"=>"1", "item_id"=>"1", "name"=>"car"},
{"id"=>"2", "item_id"=>"1", "name"=>"bicycle"}
]


sheet = spreadsheet.sheets.find {|s| s.title == 'company'}
SpreadsheetTransfer::RowSheet.new(sheet, spreadsheet.datamap[sheet.title]).name
=> 'company'
SpreadsheetTransfer::RowSheet.new(sheet, spreadsheet.datamap[sheet.title]).keys
=> ["id", "name", "country"]
SpreadsheetTransfer::RowSheet.new(sheet, spreadsheet.datamap[sheet.title]).rows
=> [["1", "apple", "usa"], ["2", "samsung", "korea"]]
SpreadsheetTransfer::RowSheet.new(sheet, spreadsheet.datamap[sheet.title]).items
=> [
{"id"=>"1", "name"=>"apple", "country"=>"usa"},
{"id"=>"2", "name"=>"samsung", "country"=>"korea"}
]

## 匯出檔案
data = SpreadsheetTransfer::ColumnSheet.new(sheet, spreadsheet.datamap[sheet.title])
SpreadsheetTransfer::Exporter::CSV.new('info.csv', data, 'path').export!
SpreadsheetTransfer::Exporter::JSON.new('info.json', data, 'path').export!

## 匯出所有 `datamap.yml` 設定的檔案
spreadsheet.export_all_to_json
spreadsheet.export_all_to_csv

```
