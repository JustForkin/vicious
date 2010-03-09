---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- FS: provides file system disk space usage
module("vicious.fs")


-- Variable definitions
local unit = { ["mb"] = 1024, ["gb"] = 1024^2 }

-- {{{ Filesystem widget type
local function worker(format, nfs)
    -- Fallback to listing only local file-systems
    if nfs then nfs = "" else nfs = "--local" end

    -- Get (non-localized)data from df
    local f = io.popen("LC_ALL=C df -kP " .. nfs)
    local fs_info = {}

    for line in f:lines() do -- Match: (size) (used)(avail)(use%) (mount)
        local s     = string.match(line, "^.-[%s]+([%d]+)")
        local u,a,p = string.match(line, "([%d]+)[%s]+([%d]+)[%s]+([%d]+)%%")
        local m     = string.match(line, "%%[%s]([%p%w]+)")

        if u and m then -- Handle 1st line and broken regexp
            helpers.uformat(fs_info, m .. " size",  s, unit)
            helpers.uformat(fs_info, m .. " used",  u, unit)
            helpers.uformat(fs_info, m .. " avail", a, unit)
            fs_info["{" .. m .. " used_p}"] = tonumber(p)
        end
    end
    f:close()

    return fs_info
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
