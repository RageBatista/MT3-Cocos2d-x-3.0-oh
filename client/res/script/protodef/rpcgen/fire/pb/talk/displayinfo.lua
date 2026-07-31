require "utils.tableutil"
DisplayInfo = {
	DISPLAY_ITEM = 1,
	DISPLAY_PET = 2,
	DISPLAY_TASK = 8,
	DISPLAY_TEAM_APPLY = 9,
	DISPLAY_ROLL_ITEM = 11,
	DISPLAY_ACTIVITY_ANSWER = 12,
	DISPLAY_LIVEDIE = 13,
	DISPLAY_BATTLE = 14,
	DISPLAY_SACE_ROLE = 15
}
DisplayInfo.__index = DisplayInfo


function DisplayInfo:new()
	local self = {}
	setmetatable(self, DisplayInfo)
	self.displaytype = 0
	self.roleid = 0
	self.shopid = 0
	self.counterid = 0
	self.uniqid = 0
	self.teamid = 0

	return self
end
function DisplayInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.displaytype)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int64(self.shopid)
	_os_:marshal_int32(self.counterid)
	_os_:marshal_int32(self.uniqid)
	_os_:marshal_int64(self.teamid)
	return _os_
end

function DisplayInfo:unmarshal(_os_)
	self.displaytype = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.shopid = _os_:unmarshal_int64()
	self.counterid = _os_:unmarshal_int32()
	self.uniqid = _os_:unmarshal_int32()
	self.teamid = _os_:unmarshal_int64()
	return _os_
end

return DisplayInfo
