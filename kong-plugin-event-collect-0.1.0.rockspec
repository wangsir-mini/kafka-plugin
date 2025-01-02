-- kong-plugin-event-collect-0.1.0-1.rockspec

--  插件名称
local plugin_name = "event-collect"
local package_name = "kong-plugin-" .. plugin_name
local package_version = "0.1.0"
local rockspec_revision = "1"

package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }


description = {
  summary = "Kong is a scalable and customizable API Management Layer built on top of Nginx.",
  license = "Apache 2.0",
}


dependencies = {
   "lua >= 5.1",
   "lua-resty-kafka"
}

-- 主要是这里的 定义插件的路径和主要的两个文件路径 =号后面根据实际填写
build = {
  type = "builtin",
  modules = {
    -- TODO: add any additional code files added to the plugin
    ["kong.plugins."..plugin_name..".handler"] = "/kong/declarative/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "/kong/declarative/"..plugin_name.."/schema.lua",
  }
}