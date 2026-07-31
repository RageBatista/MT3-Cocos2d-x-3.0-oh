require "utils.tableutil"
CSendCommand = {}
CSendCommand.__index = CSendCommand



CSendCommand.PROTOCOL_TYPE = 791433

function CSendCommand.Create()
	print("enter CSendCommand create")
	return CSendCommand:new()
end
function CSendCommand:new()
	local self = {}
	setmetatable(self, CSendCommand)
	self.type = self.PROTOCOL_TYPE
	self.cmd = "" 

	return self
end
function CSendCommand:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendCommand:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.cmd)
	return _os_
end

function CSendCommand:unmarshal(_os_)
	self.cmd = _os_:unmarshal_wstring(self.cmd)
	return _os_
end

return CSendCommand
