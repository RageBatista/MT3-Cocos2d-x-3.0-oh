require "utils.tableutil"
SendWordMsg = {}
SendWordMsg.__index = SendWordMsg



SendWordMsg.PROTOCOL_TYPE = 819071

function SendWordMsg.Create()
	print("enter SendWordMsg create")
	return SendWordMsg:new()
end
function SendWordMsg:new()
	local self = {}
	setmetatable(self, SendWordMsg)
	self.type = self.PROTOCOL_TYPE
	self.rolename = "" 
	self.servername = "" 
	self.serverid = 0
	self.worldmsg = "" 
	self.flag = 0

	return self
end
function SendWordMsg:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SendWordMsg:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_wstring(self.servername)
	_os_:marshal_int32(self.serverid)
	_os_:marshal_wstring(self.worldmsg)
	_os_:marshal_int32(self.flag)
	return _os_
end

function SendWordMsg:unmarshal(_os_)
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.servername = _os_:unmarshal_wstring(self.servername)
	self.serverid = _os_:unmarshal_int32()
	self.worldmsg = _os_:unmarshal_wstring(self.worldmsg)
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return SendWordMsg
