#!/usr/bin/lua

--[[

Copyright (C) 2015 Gui Iribarren <gui@altermundi.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this file. If not, see <http://www.gnu.org/licenses/>.

]]--

function split(string, sep)
    local ret = {}
    if string then
        for token in string.gmatch(string, "[^"..sep.."]+") do table.insert(ret, token) end
    end
    return ret
end

function merge_macs(macs1, macs2)
    local uniqmacs = {}
    for _, mac in ipairs(split(macs1, "+")) do
        uniqmacs[mac] = 1
    end
    for _, mac in ipairs(split(macs2, "+")) do
        uniqmacs[mac] = 1
    end
    local macs = {}
    for mac, _ in pairs(uniqmacs) do
        table.insert(macs, mac)
    end
    table.sort(macs)
    return table.concat(macs, "+")
end

function merge_db(db, file)
    local db_merged = db
    for line in io.lines(file) do
        id, voucher, epoch, macs = unpack(split(line, ","))
        voucher = voucher:lower()
        if macs then macs = macs:lower() end
        if type(db[voucher]) == "table" then
            if db[voucher][2] and (not epoch or tonumber(epoch) < tonumber(db[voucher][2])) then
                -- always keep the bigger epoch (most recent date)
                epoch = db[voucher][2]
            end
            if db[voucher][3] then
                macs = merge_macs(macs, db[voucher][3])
            end
        end
        
        db_merged[voucher] = {id, epoch, macs}
    end
    return db_merged
end

local db = {}

for _, file in ipairs(arg) do
    db = merge_db(db, file)
end

for voucher, attrs in pairs(db) do
    id, epoch, macs = unpack(attrs)
    if not epoch then epoch = "" end
    if not macs then macs = "" end
    print(id..","..voucher..","..epoch..","..macs)
end
