require "utils.tableutil"
CBenefitCodeExchange = {}
CBenefitCodeExchange.__index = CBenefitCodeExchange



CBenefitCodeExchange.PROTOCOL_TYPE = 817973

function CBenefitCodeExchange.Create()
	print("enter CBenefitCodeExchange create")
	return CBenefitCodeExchange:new()
end
function CBenefitCodeExchange:new()
	local self = {}
	setmetatable(self, CBenefitCodeExchange)
	self.type = self.PROTOCOL_TYPE
	self.code = "" 

	return self
end
function CBenefitCodeExchange:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBenefitCodeExchange:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.code)
	return _os_
end

function CBenefitCodeExchange:unmarshal(_os_)
	self.code = _os_:unmarshal_wstring(self.code)
	return _os_
end

return CBenefitCodeExchange
