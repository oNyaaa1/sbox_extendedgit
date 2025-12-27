sAndbox = sAndbox or {}
local time = CurTime()
/*
Added more sounds

*/
function FindShared(files)
	if string.find(files, "sh_") then
		print("Adding Shared File: " .. files)
		if SERVER then
			AddCSLuaFile(files)
			include(files)
		else
			include(files)
		end
	end

	if string.find(files, "sv_") then
		print("Adding Server File: " .. files)
		if SERVER then include(files) end
	end

	if string.find(files, "cl_") then
		if SERVER then
			AddCSLuaFile(files)
			include(files)
			print("Adding Client File: " .. files)
		else
			include(files)
			print("Adding Client File: " .. files)
		end
	end
end

function FindFiles(duh)
	local fillBind = {}
	local start = "sbox_extended/"
	local files = file.Find(start .. "/" .. duh .. "/*", "LUA")
	for k, v in pairs(files) do
		fillBind[#fillBind + 1] = start .. duh .. "/" .. v
	end

	for k, v in ipairs(fillBind) do
		FindShared(v)
	end
end

FindFiles("shared")
FindFiles("server")
FindFiles("client")
local time2 = CurTime()
print("[sAndbox FrameWork] Took " .. math.Round(time + time2, 2) .. " Seconds to Load!")