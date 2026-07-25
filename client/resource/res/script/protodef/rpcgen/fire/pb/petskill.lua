require "utils.tableutil"
Petskill = {}
Petskill.__index = Petskill


function Petskill:new()
	local self = {}
	setmetatable(self, Petskill)
	self.skillid = 0
	self.skillexp = 0
	self.skilltype = 0
	self.certification = 0

	return self
end
function Petskill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.skillid)
	_os_:marshal_int32(self.skillexp)
	_os_:marshal_char(self.skilltype)
	_os_:marshal_char(self.certification)
	return _os_
end

function Petskill:unmarshal(_os_)
	self.skillid = _os_:unmarshal_int32()
	self.skillexp = _os_:unmarshal_int32()
	self.skilltype = _os_:unmarshal_char()
	self.certification = _os_:unmarshal_char()
	return _os_
end

return Petskill
