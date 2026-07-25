require "utils.tableutil"
COneKeyApplyClan = {}
COneKeyApplyClan.__index = COneKeyApplyClan



COneKeyApplyClan.PROTOCOL_TYPE = 808488

function COneKeyApplyClan.Create()
	print("enter COneKeyApplyClan create")
	return COneKeyApplyClan:new()
end
function COneKeyApplyClan:new()
	local self = {}
	setmetatable(self, COneKeyApplyClan)
	self.type = self.PROTOCOL_TYPE
	return self
end
function COneKeyApplyClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COneKeyApplyClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function COneKeyApplyClan:unmarshal(_os_)
	return _os_
end

return COneKeyApplyClan
