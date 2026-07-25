require "utils.tableutil"
SBeginCorssServer = {}
SBeginCorssServer.__index = SBeginCorssServer



SBeginCorssServer.PROTOCOL_TYPE = 819115

function SBeginCorssServer.Create()
	print("enter SBeginCorssServer create")
	return SBeginCorssServer:new()
end
function SBeginCorssServer:new()
	local self = {}
	setmetatable(self, SBeginCorssServer)
	self.type = self.PROTOCOL_TYPE
	self.account = "" 
	self.ticket = "" 
	self.crossip = "" 
	self.crossport = 0
	self.crossnum = 0

	return self
end
function SBeginCorssServer:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBeginCorssServer:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.account)
	_os_:marshal_wstring(self.ticket)
	_os_:marshal_wstring(self.crossip)
	_os_:marshal_int32(self.crossport)
	_os_:marshal_int32(self.crossnum)
	return _os_
end

function SBeginCorssServer:unmarshal(_os_)
	self.account = _os_:unmarshal_wstring(self.account)
	self.ticket = _os_:unmarshal_wstring(self.ticket)
	self.crossip = _os_:unmarshal_wstring(self.crossip)
	self.crossport = _os_:unmarshal_int32()
	self.crossnum = _os_:unmarshal_int32()
	return _os_
end

return SBeginCorssServer
