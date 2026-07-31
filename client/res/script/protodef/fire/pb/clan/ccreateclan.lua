require "utils.tableutil"
CCreateClan = {}
CCreateClan.__index = CCreateClan



CCreateClan.PROTOCOL_TYPE = 808450

function CCreateClan.Create()
	print("enter CCreateClan create")
	return CCreateClan:new()
end
function CCreateClan:new()
	local self = {}
	setmetatable(self, CCreateClan)
	self.type = self.PROTOCOL_TYPE
	self.clanname = "" 
	self.clanaim = "" 

	return self
end
function CCreateClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCreateClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.clanname)
	_os_:marshal_wstring(self.clanaim)
	return _os_
end

function CCreateClan:unmarshal(_os_)
	self.clanname = _os_:unmarshal_wstring(self.clanname)
	self.clanaim = _os_:unmarshal_wstring(self.clanaim)
	return _os_
end

return CCreateClan
