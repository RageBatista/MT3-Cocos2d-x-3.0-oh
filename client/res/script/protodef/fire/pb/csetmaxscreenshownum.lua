require "utils.tableutil"
CSetMaxScreenShowNum = {}
CSetMaxScreenShowNum.__index = CSetMaxScreenShowNum



CSetMaxScreenShowNum.PROTOCOL_TYPE = 786495

function CSetMaxScreenShowNum.Create()
	print("enter CSetMaxScreenShowNum create")
	return CSetMaxScreenShowNum:new()
end
function CSetMaxScreenShowNum:new()
	local self = {}
	setmetatable(self, CSetMaxScreenShowNum)
	self.type = self.PROTOCOL_TYPE
	self.maxscreenshownum = 0

	return self
end
function CSetMaxScreenShowNum:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetMaxScreenShowNum:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.maxscreenshownum)
	return _os_
end

function CSetMaxScreenShowNum:unmarshal(_os_)
	self.maxscreenshownum = _os_:unmarshal_short()
	return _os_
end

return CSetMaxScreenShowNum
