require "utils.tableutil"
CReqLianYaoBuyItems = {
}
CReqLianYaoBuyItems.__index = CReqLianYaoBuyItems



CReqLianYaoBuyItems.PROTOCOL_TYPE = 810517

function CReqLianYaoBuyItems.Create()
	print("enter CReqLianYaoBuyItems create")
	return CReqLianYaoBuyItems:new()
end
function CReqLianYaoBuyItems:new()
	local self = {}
	setmetatable(self, CReqLianYaoBuyItems)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqLianYaoBuyItems:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqLianYaoBuyItems:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqLianYaoBuyItems:unmarshal(_os_)
	return _os_
end

return CReqLianYaoBuyItems
