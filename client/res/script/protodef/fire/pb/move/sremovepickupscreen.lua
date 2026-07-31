require "utils.tableutil"
SRemovePickupScreen = {}
SRemovePickupScreen.__index = SRemovePickupScreen



SRemovePickupScreen.PROTOCOL_TYPE = 790446

function SRemovePickupScreen.Create()
	print("enter SRemovePickupScreen create")
	return SRemovePickupScreen:new()
end
function SRemovePickupScreen:new()
	local self = {}
	setmetatable(self, SRemovePickupScreen)
	self.type = self.PROTOCOL_TYPE
	self.pickupids = {}

	return self
end
function SRemovePickupScreen:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRemovePickupScreen:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.pickupids))
	for k,v in ipairs(self.pickupids) do
		_os_:marshal_int64(v)
	end

	return _os_
end

function SRemovePickupScreen:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_pickupids=0 ,_os_null_pickupids
	_os_null_pickupids, sizeof_pickupids = _os_: uncompact_uint32(sizeof_pickupids)
	for k = 1,sizeof_pickupids do
		self.pickupids[k] = _os_:unmarshal_int64()
	end
	return _os_
end

return SRemovePickupScreen
