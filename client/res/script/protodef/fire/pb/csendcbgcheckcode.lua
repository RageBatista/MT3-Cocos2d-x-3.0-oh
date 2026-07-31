require "utils.tableutil"
CSendCBGCheckCode = {}
CSendCBGCheckCode.__index = CSendCBGCheckCode



CSendCBGCheckCode.PROTOCOL_TYPE = 786584

function CSendCBGCheckCode.Create()
	print("enter CSendCBGCheckCode create")
	return CSendCBGCheckCode:new()
end
function CSendCBGCheckCode:new()
	local self = {}
	setmetatable(self, CSendCBGCheckCode)
	self.type = self.PROTOCOL_TYPE
	self.code = "" 

	return self
end
function CSendCBGCheckCode:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendCBGCheckCode:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.code)
	return _os_
end

function CSendCBGCheckCode:unmarshal(_os_)
	self.code = _os_:unmarshal_wstring(self.code)
	return _os_
end

return CSendCBGCheckCode
