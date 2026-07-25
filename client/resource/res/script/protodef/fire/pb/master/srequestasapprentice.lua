require "utils.tableutil"
SRequestAsApprentice = {}
SRequestAsApprentice.__index = SRequestAsApprentice



SRequestAsApprentice.PROTOCOL_TYPE = 816440

function SRequestAsApprentice.Create()
	print("enter SRequestAsApprentice create")
	return SRequestAsApprentice:new()
end
function SRequestAsApprentice:new()
	local self = {}
	setmetatable(self, SRequestAsApprentice)
	self.type = self.PROTOCOL_TYPE
	self.prenticeid = 0
	self.prenticename = "" 
	self.school = 0
	self.level = 0
	self.requestword = "" 

	return self
end
function SRequestAsApprentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestAsApprentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.prenticeid)
	_os_:marshal_wstring(self.prenticename)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.level)
	_os_:marshal_wstring(self.requestword)
	return _os_
end

function SRequestAsApprentice:unmarshal(_os_)
	self.prenticeid = _os_:unmarshal_int64()
	self.prenticename = _os_:unmarshal_wstring(self.prenticename)
	self.school = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.requestword = _os_:unmarshal_wstring(self.requestword)
	return _os_
end

return SRequestAsApprentice
