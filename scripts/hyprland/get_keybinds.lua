local binds = {}

_G.hl = {
    bind = function(keycombo, action, opts)
        opts = opts or {}
        local desc = opts.description
        if desc then
            table.insert(binds, {
                combo = keycombo,
                description = desc
            })
        end
    end,
    dsp = setmetatable({}, {
        __index = function(t, k) 
            return function() return "action" end 
        end
    }),
    exec_cmd = function() return "exec" end,
    get_active_workspace = function() return {id = 1} end,
    notification = { create = function() end },
    define_submap = function() end,
    get_config = function() return 1.0 end,
    config = function() end,
    dispatch = function() end,
    get_current_submap = function() return "" end
}
_G.hl.dsp.global = function() return "global" end
_G.hl.dsp.exec_cmd = function() return "exec" end
_G.hl.dsp.window = setmetatable({}, {__index = function() return function() return "" end end})
_G.hl.dsp.workspace = setmetatable({}, {__index = function() return function() return "" end end})
_G.hl.dsp.layout = function() return "" end
_G.hl.dsp.focus = function() return "" end
_G.hl.dsp.submap = function() return "" end

_G.is_file_exists = function() return false end
_G.workspaceGroupSize = 10
_G.HOME = os.getenv("HOME") or "/home/pu94x"

_G.terminal = "kitty"
_G.fileManager = "thunar"
_G.browser = "firefox"
_G.codeEditor = "code"
_G.officeSoftware = "libreoffice"
_G.textEditor = "geany"
_G.volumeMixer = "pavucontrol"
_G.settingsApp = "gnome-control-center"

local old_require = require
_G.require = function(mod) pcall(old_require, mod) end

pcall(dofile, "/home/pu94x/.config/hypr/hyprland/keybinds.lua")

print("[")
for i, bind in ipairs(binds) do
    local combo = bind.combo
    local parts = {}
    for part in string.gmatch(combo, "[^+]+") do
        table.insert(parts, part:match("^%s*(.-)%s*$"))
    end
    local key = parts[#parts]
    if key:sub(1, 5) == "code:" then key = key:sub(6) end
    if key:sub(1, 6) == "mouse:" then key = key end
    local modmask = 0
    for j=1, #parts-1 do
        local m = parts[j]:upper()
        if m:find("SHIFT") then modmask = modmask + 1
        elseif m:find("CAPS") then modmask = modmask + 2
        elseif m:find("CTRL") then modmask = modmask + 4
        elseif m:find("ALT") then modmask = modmask + 8
        elseif m:find("MOD2") then modmask = modmask + 16
        elseif m:find("MOD3") then modmask = modmask + 32
        elseif m:find("SUPER") then modmask = modmask + 64
        elseif m:find("MOD5") then modmask = modmask + 128
        end
    end
    
    local desc = bind.description:gsub('"', '\\"')
    local key_escaped = key:gsub('"', '\\"')
    io.write(string.format('  {"key": "%s", "modmask": %d, "description": "%s"}', key_escaped, modmask, desc))
    if i < #binds then print(",") else print("") end
end
print("]")
