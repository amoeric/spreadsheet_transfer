# SpreadsheetTransfer


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spreadsheet_transfer', git: 'https://github.com/amoeric/spreadsheet_transfer.git'
```

And then execute:

    $ bundle install



## (O) 支援格式


#### row
|流水號|姓名|地址|  
| ------------- | ------------- | ------------- |  
|id|name|address|  
|1|eric|taiwan|  

or

|id|name|address|  
| ------------- | ------------- | ------------- |  
|1|eric|taiwan|  

#### col
|流水號|id|1|  
| ------------- | ------------- | ------------- |  
|姓名|name|eric|  
|地址|address|taiwan|  

or

|id|1|  
| ------------- | ------------- |  
|name|eric|  
|address|taiwan|  


## (Ｘ) 不支援  

欄位中的排序號  
|id|1|name|address|
| ------------- | ------------- | ------------- | ------------- |  
|1 |2|eric|taiwan|

資料下方註解  
|id   |name |address|
| ------------- | ------------- | ------------- |
|1    |eric |taiwan|
|''   |''   |''|
|'註解'|'註解'|''|

-----------------



## Usage

### 1. 設定 service_account.json

> 申請的 google spreadsheet api json 檔

### 2. 設定 datamap.yml

資料架構

```
company:
  filename: 'company_base'
  first_key_x: 1
  first_key_y: 2
  data_order: 'row'
  export_dir: 'data'
  replace_keys:
    company_country: 'country'
  replace_items:
    img_name:
      '-': 0
      '○': 1
```

架構說明
> 以上面的資料架構說明

| 欄位  | 用途 |
| ------------- | ------------- |
| company  |  分頁名稱 |
| filename  | 產出的檔案名稱  |
| first_key_x  | 第一個 key X 位置，ex: A2 cell，first_key_x: 1 、 first_key_y: 2 |
| first_key_y  | 第一個 key Y 位置 |
| data_order  | 每筆資料排序，分為 ``'col'`` 或 `'row'` |
| export_dir  | 匯出路徑 |
| replace_keys  | 把 key 改成想要的，EX: company_country: 'country'， 會將 sheet 中的 `company_country` key 改成 `country` |
| replace_items  | 變更指定欄位對應內容，EX: '○': 1，會把 img_name 內容為 '○' 的欄位更改為 `1` |


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
#<SpreadsheetTransfer::RowSheet:0x00007ff2ac5836e8 @worksheet=#<GoogleDrive::Worksheet spreadsheet_id="12234235454WSA8Bqweqe122", gid="1234556", title="company">, @datamap={"filename"=>"company", "first_key_x"=>1, "first_key_y"=>2, "data_order"=>"row", "export_dir"=>"spreadsheet_data"}>,
#<SpreadsheetTransfer::ColumnSheet:0x00007ff2ac5836e8 @worksheet=#<GoogleDrive::Worksheet spreadsheet_id="12234235454WSA8Bqweqe122", gid="1234556", title="col_company">, @datamap={"filename"=>"company", "first_key_x"=>1, "first_key_y"=>2, "data_order"=>"row", "export_dir"=>"spreadsheet_data"}>
]


sheet = spreadsheet.sheets.find {|s| s.title == 'company'}
sheet.name
=> 'company'
sheet.keys
=> ["id", "name", "country"]
sheet.rows
=> [["1", "apple", "usa"], ["2", "samsung", "korea"]]
sheet.items
=> [
{"id"=>"1", "name"=>"apple", "country"=>"usa"},
{"id"=>"2", "name"=>"samsung", "country"=>"korea"}
]

## 匯出檔案
SpreadsheetTransfer::Exporter::CSV.new('info.csv', sheet, 'path').export!
SpreadsheetTransfer::Exporter::JSON.new('info.json', sheet, 'path').export!

## 匯出所有 `datamap.yml` 設定的檔案
spreadsheet.export_all_to_json
spreadsheet.export_all_to_csv

```
