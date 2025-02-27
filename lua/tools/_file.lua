#! /usr/bin/env lua
--
-- _file.lua
-- Copyright (C) 2022 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--
-- global function of fileutils
-- bool file_exists( full_path )
-- bool isDir(full_path)
-- bool isFile(full_path)
--
-- full_path, dir, file  get_full_path(filename) -- return  "<user_dir>/>path" or "<shared_dir/>path"

--  global function isFile isDir
function file_exists(path)
    if type(path)~="string" then return false end
    return os.rename(path,path) and true or false
end

function isFile(path)
    if not file_exists(path) then return false end
    local f = io.open(path)
    if f then
      local res = f:read(1) and true or false
      f:close()
      return res
    end
    return false
end

function isDir(path)
    return (file_exists(path) and not isFile(path))
end
-- return full_path


-- return require_path,source_file
-- example:    package.path= "xxxxxx/xxxxxx/lua/?.lua;xxxxxx/xxxxxx/lua/?/init.lua"
-- current file =xxxxxx/xxxxx/lua/tools/_file.lua
-- path,file, full_path= rpath() -- return  "tools", "_file.lua" , xxxxx/xxxxx
function rpath(n)
  n= n or 2
  local source_file =  debug.getinfo(n,'S').short_src
  local path ,file= source_file:match("^(.+)/(.*.lua)$")
  path = path and path:match("/lua/(.+)$")
  return path,file,source_file
end
