require "utils.tableutil"
SClanAim = {}
SClanAim.__index = SClanAim



SClanAim.PROTOCOL_TYPE = 808480

function SClanAim.Create()
	print("enter SClanAim create")
	return SClanAim:new()
end
function SClanAim:new()
	local self = {}
	setmetatable(self, SClanAim)
	self.type = self.PROTOCOL_TYPE
	self.clanid = 0
	self.clanaim = "" 
	self.oldclanname = "" 

	return self
end
function SClanAim:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SClanAim:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clanid)
	_os_:marshal_wstring(self.clanaim)
	_os_:marshal_wstring(self.oldclanname)
	return _os_
end

function SClanAim:unmarshal(_os_)
	self.clanid = _os_:unmarshal_int64()
	self.clanaim = _os_:unmarshal_wstring(self.clanaim)
	self.oldclanname = _os_:unmarshal_wstring(self.oldclanname)
	return _os_
end

return SClanAim
