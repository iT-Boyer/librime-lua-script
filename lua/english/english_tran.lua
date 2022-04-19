local puts=require 'tools/debugtool'
local D01= nil

local English_dict= require 'tools/english_dict'


local function njload()
  -- try to load wordninja-lua
  -- https://github.com/BlindingDark/wordninja-rs-lua
  -- rime.lua append
  -- cp wordninja.so  <user_data_dir>/lua/plugin
  --
  -- window lua 版本不符將造成暫時取消 window版本 載入 wordnanja-rs
  local nj = require 'tools/wordninja'
  return nj
end

local English="english"
local Ninja="ninja"

local function load_ext_dict(filename)
  local path= string.gsub(debug.getinfo(1).source,"^@(.+/)[^/]+$", "%1")
  filename =  path ..  (filename or "english.txt" )
  local tab = {}
  for line in io.open(filename):lines() do
    puts(D01, __FILE__(), line)
    if not line:match("^#") then  -- 第一字 #  不納入字典
      local t=line:split("\t")
      if t then
        tab[t[1]] = t[2]
      end
    end
  end
  return tab
end

local T={}


function T.init(env)
  local config= env.engine.schema.config
  env.tag= config:get_string(env.name_space .. "/tag") or English

  local dict= config:get_string(env.name_space .. "/dictionary") or "english_tw"
  T._eng_dict= T._eng_dict or English_dict(dict .. ".txt")
  T._nj= T._nj or njload()
  T._ext_dict= T._ext_dict or load_ext_dict("ext_dict.txt")
  puts(CONSOLE, __FILE__(), package.cpath,"\n\n",  package.path )

  env.gsub_fmt =  package.config:sub(1,1) == "/" and "\n" or "\r"


end
function T.fini(env)
end

local function sync_case(input, candidate_word)
  if input:match("^%u%u") then
    return candidate_word:upper()
  elseif input:match("^%u") then
    return candidate_word:gsub("^%a",string.upper)
  else
    return candidate_word
  end
end
function T.func(inp,seg,env)
  local context=env.engine.context

  if not ( seg:has_tag(env.tag) or context:get_option(English) )  then return end

  local input =  seg:has_tag("lua_cmd") and inp:sub(2) or inp:sub(seg.start,seg._end)

  input = input:match("^[%a][%a_.'/*:%-]*$") and input or ""
  if #input==0 then return end

  --puts("trace",__FILE__(),__FUNC__(),"----english-----", input  )

  local first=T._ext_dict[input:lower()]
     and Candidate("english_ext", seg.start, seg._end, input , "[".. T._ext_dict[input:lower()] .. "]")
     or Candidate(English, seg.start, seg._end, input , "[english]")
  yield(first)

  local commit= input:match("^[%a%_%.%']+$")  and T._nj.split(input) or {}
  if #commit > 1 then
    yield( Candidate(Ninja, seg.start,seg._end, commit, "[ninja]"))
  end

  -- 使用 context.input 杳字典 type "english"
  for w in T._eng_dict:iter(inp:sub(seg.start,seg._end)) do
    -- 如果 與 字典相同 替換 first cand.comment
    if first.type == English and input == w.word or input:lower() == w.word then
      first.comment= w.info:gsub("\\n", env.gsub_fmt)
    else
      yield( Candidate(English,seg.start,seg._end,sync_case(input,w.word),w.info:gsub("\\n",env.gsub_fmt)) )
    end
  end
  -- 使用 ninja 最後一佪字查字典 type "ninja"
  if #commit > 1 then
    --local n_word= commit[#commit]
    local n_word= commit:match(".* (.+)$")

    for w in T._eng_dict:iter(n_word) do
      -- seg.start =   seg.end - #m_word
      yield( Candidate(Ninja, seg._end - #n_word , seg._end,w.word,"(Ninja) " .. w.info:gsub("\\n",env.gsub_fmt)))
    end
  end
end


return T
