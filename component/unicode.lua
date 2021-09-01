#! /usr/bin/env lua
--
-- ttt.lua
-- Copyright (C) 2021 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--

-- 1 copy this file in  lua/uincode.lua
-- 2 rime.lua
--   uincode = require('unicode') 
--
-- 3 schema.yaml
--   recognizer/patterns/unicode: "U[a-h0-9]+" 
--   engine/translators
--     - lua_translator@unicode  -- append  
--

--  unicode(number)  to utf8 (char)
--

--[[
local function unicode(u) 
  if u >>7 == 0 then return string.char(u) end 
  local count = 0x80 
  local tab={} 
  repeat 
    count = count >> 1 | 0x80 
    table.insert(tab,1, u & 0x3f |0x80 )
    u = u >> 6 
  until u < 0xc0 
  table.insert(tab,1,count | u )
  for i,v in ipairs(tab) do print(i,v) end 
  return string.char( table.unpack(tab)  )
end 

print( 
   unicode(   tonumber("8a9e",16)  ) -- 語
   )
print(type(utf8))
--]]


local function init(env)
end 
local function fini(env)
end 
-- Ucode,code,code....
-- patterns: 
--    unicode: "U([a-h0-9]+,?)+"  
local function func3(input,seg,env)
  local iii= env.engine.context.input
  if seg:has_tag("unicode") then 
    local ucodestr=  input:sub( seg.start+2, seg._end)   
    print("=====>",iii,input, ucodestr,seg.start,seg._end)
    local tab={} 
    for item in ucodestr:gmatch("([a-f0-9]+),?") do 
      table.insert(tab,tonumber(item,16) )
    end 
    yield(
      Candidate( "unicode", seg.start, seg._end,
       utf8.char(table.unpack(tab)), string.format("%s,%d,%d",ucodestr,seg.start,seg._end) )
    )
  end
end
local function func2(input,seg,env)
  if seg:has_tag("unicode") then 
    local ucode= tonumber( input:sub( seg.start+2, seg._end) , 16)  
    yield(
      Candidate( "unicode", seg.start, seg._end,
       utf8.char( ucode ), string.format("0x%X",ucode) )
    )
  end
end
local function func(input, seg,env)
  if seg:has_tag("unicode") then 
    local ucode=  tonumber( input:sub(seg.start+2, seg._end), 16) 
    local text= utf8.char( ucode )
    local comment =   string.format("0x%X %d %d" ,ucode  , seg.start,seg._end)
    yield(
      Candidate( "unicode", seg.start,seg._end , text ,comment ) )
  end
end 
return {init=init,fini=fini,func=func3 }

