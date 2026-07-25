require "utils.tableutil"
CSendRequestWordToPrentice = {}
CSendRequestWordToPrentice.__index = CSendRequestWordToPrentice



CSendRequestWordToPrentice.PROTOCOL_TYPE = 816465

function CSendRequestWordToPrentice.Create()
	print("enter CSendRequestWordToPrentice create")
	return CSendRequestWordToPrentice:new()
end
function CSendRequestWordToPrentice:new()
	local self = {}
	setmetatable(self, CSendRequestWordToPrentice)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.requestword = "" 

	return self
end
function CSendRequestWordToPrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendRequestWordToPrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.requestword)
	return _os_
end

function CSendRequestWordToPrentice:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.requestword = _os_:unmarshal_wstring(self.requestword)
	return _os_
end

return CSendRequestWordToPrentice
