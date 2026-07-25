require "utils.tableutil"
CMissionDialogEnd = {}
CMissionDialogEnd.__index = CMissionDialogEnd



CMissionDialogEnd.PROTOCOL_TYPE = 805458

function CMissionDialogEnd.Create()
	print("enter CMissionDialogEnd create")
	return CMissionDialogEnd:new()
end
function CMissionDialogEnd:new()
	local self = {}
	setmetatable(self, CMissionDialogEnd)
	self.type = self.PROTOCOL_TYPE
	self.missionid = 0

	return self
end
function CMissionDialogEnd:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMissionDialogEnd:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	return _os_
end

function CMissionDialogEnd:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	return _os_
end

return CMissionDialogEnd
