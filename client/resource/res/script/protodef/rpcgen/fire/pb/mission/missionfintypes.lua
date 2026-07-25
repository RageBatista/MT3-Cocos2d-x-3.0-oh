require "utils.tableutil"
MissionFinTypes = {
	NUL = 0,
	MONEY = 1,
	ITEM = 2,
	PET = 3,
	COUNT = 4,
	ITEMCOUNT = 5,
	AREA = 6,
	QUESTION = 7,
	LEVEL = 8,
	OTHER = 9
}
MissionFinTypes.__index = MissionFinTypes


function MissionFinTypes:new()
	local self = {}
	setmetatable(self, MissionFinTypes)
	return self
end
function MissionFinTypes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function MissionFinTypes:unmarshal(_os_)
	return _os_
end

return MissionFinTypes
