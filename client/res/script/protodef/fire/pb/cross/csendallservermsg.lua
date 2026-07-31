require "utils.tableutil"
CSendAllServerMsg = {}
CSendAllServerMsg.__index = CSendAllServerMsg



CSendAllServerMsg.PROTOCOL_TYPE = 819119

function CSendAllServerMsg.Create()
	print("enter CSendAllServerMsg create")
	return CSendAllServerMsg:new()
end
function CSendAllServerMsg:new()
	local self = {}
	setmetatable(self, CSendAllServerMsg)
	self.type = self.PROTOCOL_TYPE
	self.worldmsg = "" 
	self.flag = 0

	return self
end
function CSendAllServerMsg:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendAllServerMsg:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.worldmsg)
	_os_:marshal_int32(self.flag)
	return _os_
end

function CSendAllServerMsg:unmarshal(_os_)
	self.worldmsg = _os_:unmarshal_wstring(self.worldmsg)
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return CSendAllServerMsg
