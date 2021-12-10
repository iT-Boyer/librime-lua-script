# librime-lua-script
## multi_reverse 主副字典反查(新版)  支持 librime-lua(新舊版)
自動導入 engine/translators/   script_translator table_translator   反查 lua_filter
### 反查字典切換
* Ctrl+6 反查開關
* ctrl+7 反查碼顯示最短碼開關
* ctrl+8 未完成碼上屏開關 
* Ctrl+9 反查碼filter 切換(正) 
* Ctrl+0 反查碼filter 切換(負)
### 安裝
* rime.lua
```lua
require 'tools/rime_api'   -- 擴充 rime_api table 接口 
require 'multi_reverse'    -- 載入 multi_reverse_processor multi_reverse_filter
assert( multi_reverse_processor) 
```
* schema_id.custom.yaml 
``` 
patch: 
   engine/processors/@after 0: lua_processor@multi_reverse_processor
```
## 聯想詞彙 conjunctive.lua (支援librime-lua Commits on Oct 11, 2020 版本)

利用 commit_notifier & update_notifier & engine.process_key context.input(~ ~)  ~~重送 KeyEvent(~)~~ , 觸發 lua_translator@conjunctive 產生聯想詞彙

增加聯想開關(F11)
 *增加 (~) 觸發聯想(~ ~)字串處理   
   * [><~] : 刪字 ~ < 刪字尾   > 刪字首，變更時下面聯想詞也會更新重組， 織 backspace 恢復上一字元  space 變更 env.history
   * C : 清除 space 變更 env.history=""
   * B : 還原上次異動 space 變更 env.history= env.history_back
   * H : user 常用詞 選屏上字  
   




自動載入參數據( lua_translator@conjunctive and module ) 插入 echo_translator後   punct_translator前

### 安裝
```
-- copy file  to user_data_dir/lua  
lua/tools/list.lua  -- list module 
lua/tools/ditc.lua  -- 聯想詞彙 module 
lua/conjunctive.lua  -- 主程式

--- rime.lua
conjunctive_proc= require('conjunctive')
---  custom.yaml
patch:
  engine/processors/@after 0: lua_processor@conjunctive_proc

```
### 設定值
```lua
-- conjunctive.lua 設定參數
 -- 使用者常用詞                             
 _HISTORY={                                   
 "發性進行性失語",                            
 "發性症狀",                                  
 "發性行性失語症狀",                          
 "發性進行失語症狀",                          
 "發進行性失症狀",                            
 "發性進行失語症狀",                          
 "性進行失語症狀",                            
 "發性行性失語症狀",                          
 "進行性失語症狀",                            
 }                                            
                                              
-- user define data
local pattern_str="~"  -- 聯想觸發 keyevent
local lua_tran_ns="conjunctive" 
local dict_file= 'essay.txt'
local switch_key="F11" -- 聯想詞開闢 預設 0  on  1 off , keybinder {when:always,accept: F11, toggle: conjunctive}

```

## [tools 常用工具](https://github.com/shewer/librime-lua-script/tools/README.md)
* list.lua 提供 each map reduce select ... 
* string 擴充 utf8.sub string.split string.utf8_sub string.utf8_len string.utf8_offset 
* rime_api.lua 擴充 rime_api globl function Env(env) Init_projection(config,path)
* dict.lua 聯想詞查表 
* key_binder.lua 類 keybind 提供 lua_processor 熱鍵
* pattern.lua librime-lua 舊版無支援 ProjectionReg 改由 lua 實現 pattern 轉換   preedit_format commit_format
* inspect.lua -- 源自 luarocks 安裝 
* json.lua  -- 源自 luarocks 安裝
* luaunit.lua testunit  -- 源自 luarocks 安裝
     
## test luaunit 測試資料夾


