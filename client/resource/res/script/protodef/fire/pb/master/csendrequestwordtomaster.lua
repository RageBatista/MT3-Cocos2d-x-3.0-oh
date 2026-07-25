require "utils.tableutil"
CSendRequestWordToMaster = {}
CSendRequestWordToMaster.__index = CSendRequestWordToMaster



CSendRequestWordToMaster.PROTOCOL_TYPE = 816463

function CSendRequestWordToMaster.Create()
	print("enter CSendRequestWordToMaster create")
	return CSendRequestWordToMaster:new()
end
function CSendRequestWordToMaster:new()
	local self = {}
	setmetatable(self, CSendRequestWordToMaster)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.requestword = "" 

	return self
end
function CSendRequestWordToMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendRequestWordToMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.requestword)
	return _os_
end

function CSendRequestWordToMaster:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.requestword = _os_:unmarshal_wstring(self.requestword)
	return _os_
end

return CSendRequestWordToMaster
