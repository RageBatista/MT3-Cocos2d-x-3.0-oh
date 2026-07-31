require "utils.tableutil"
SReceiveNewPrentice = {}
SReceiveNewPrentice.__index = SReceiveNewPrentice



SReceiveNewPrentice.PROTOCOL_TYPE = 816457

function SReceiveNewPrentice.Create()
	print("enter SReceiveNewPrentice create")
	return SReceiveNewPrentice:new()
end
function SReceiveNewPrentice:new()
	local self = {}
	setmetatable(self, SReceiveNewPrentice)
	self.type = self.PROTOCOL_TYPE
	self.prenticeid = 0
	self.prenticename = "" 

	return self
end
function SReceiveNewPrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReceiveNewPrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.prenticeid)
	_os_:marshal_wstring(self.prenticename)
	return _os_
end

function SReceiveNewPrentice:unmarshal(_os_)
	self.prenticeid = _os_:unmarshal_int64()
	self.prenticename = _os_:unmarshal_wstring(self.prenticename)
	return _os_
end

return SReceiveNewPrentice
