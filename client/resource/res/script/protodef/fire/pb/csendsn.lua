require "utils.tableutil"
CSendSn = {}
CSendSn.__index = CSendSn



CSendSn.PROTOCOL_TYPE = 786510

function CSendSn.Create()
	print("enter CSendSn create")
	return CSendSn:new()
end
function CSendSn:new()
	local self = {}
	setmetatable(self, CSendSn)
	self.type = self.PROTOCOL_TYPE
	self.snstr = "" 

	return self
end
function CSendSn:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendSn:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.snstr)
	return _os_
end

function CSendSn:unmarshal(_os_)
	self.snstr = _os_:unmarshal_wstring(self.snstr)
	return _os_
end

return CSendSn
