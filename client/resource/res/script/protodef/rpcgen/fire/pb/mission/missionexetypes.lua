require "utils.tableutil"
MissionExeTypes = {
	NUL = 5,
	NPC = 1,
	USE = 2,
	PRACTISEAREA = 3,
	AIBATTLE = 4,
	PATROL = 6,
	BUY = 7,
	SKILLUP = 8,
	EQUIP = 9
}
MissionExeTypes.__index = MissionExeTypes


function MissionExeTypes:new()
	local self = {}
	setmetatable(self, MissionExeTypes)
	return self
end
function MissionExeTypes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function MissionExeTypes:unmarshal(_os_)
	return _os_
end

return MissionExeTypes
