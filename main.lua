local io = require("io")
local http = require("socket.http")

local config = require("config")
local csv = require("csv")

-- Just some feedback, CSV fetching and parsing take a little bit of time
print("Loading...")

--[[
	This contain our working table, it's organized this way
	datacenter_id = {
		raw_data = "raw CSV",
		raw_status = {} -- All the lines from the parsed CSV
		groups = {
			name = "Pretty name from config",
			data = {} -- all the servers in a group
		}
	}
]]
local data = {}

-- Get CSV data and populate the working table
for dc_id, conf in pairs(config) do
	dc = {}
	dc.raw_status = {}
	dc.raw_data = http.request(conf.url)
	for line in string.gmatch(dc.raw_data,'[^\r\n]+') do
		table.insert(dc.raw_status, csv.parse(line))
	end
	dc.groups = {}
	for group_id, group_data in pairs(conf.groups) do
		dc.groups[group_id] = {}
		dc.groups[group_id].name = group_data.name
		dc.groups[group_id].data = {}
	end
	data[dc_id] = dc
end

-- Sort the servers by group
for dc_name, dc_data in pairs(data) do
	for k,v in pairs (dc_data.raw_status) do
		for sk, sv in pairs (config[dc_name].groups) do
			if v[2] ~= "BACKEND" and v[2] ~= "FRONTEND" and v[1] == sv.group then
				table.insert(dc_data.groups[sk].data, v)
			end
		end
	end
end

-- Check server status
for dc_id, conf in pairs(config) do
	local dc = data[dc_id]
	print(conf.name.." servers:")
	for k,v in pairs(dc.groups) do
		local is_ok = true
		for sk, sv in pairs(v.data) do
			if  sv[18] ~= "UP" then
				if is_ok == true then
					is_ok = false
					print("\t"..v.name.." is \27[31mNOT OK\27[0m:")
				end
				print("\t\t\27[31mPROBLEM on\27[0m "..sv[2]..": "..sv[18])
			end
		end
		if is_ok == true then
			print("\t"..v.name.." is \27[32mOK\27[0m")
		end
	end
end
