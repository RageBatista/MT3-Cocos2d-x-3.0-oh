require "utils.tableutil"
CLotteryMount = {}
CLotteryMount.__index = CLotteryMount



CLotteryMount.PROTOCOL_TYPE = 810514

function CLotteryMount.Create()
	print("enter CLotteryMount create")
	return CLotteryMount:new()
end
function CLotteryMount:new()
	local self = {}
	setmetatable(self, CLotteryMount)
	self.type = self.PROTOCOL_TYPE
 	return self
end
function CLotteryMount:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLotteryMount:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CLotteryMount:unmarshal(_os_)
	return _os_
end

return CLotteryMount
