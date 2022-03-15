### 使い方
- chorome_driverをインストール
https://chromedriver.chromium.org/downloads

下記のコマンドを、9:58 +09:00:00に定期実行する
```
ruby wakasu.rb
```

### 更新方法
下記の、reserveに渡している第四引数は稀に変更がある。choromeの検証ツールで調べる(chrome_inspect_tool.pngを参照)
```
driver.execute_script("reserve(#{target_date.year}, #{target_date.month}, #{target_date.day}, 54, 4, 1)")
```
