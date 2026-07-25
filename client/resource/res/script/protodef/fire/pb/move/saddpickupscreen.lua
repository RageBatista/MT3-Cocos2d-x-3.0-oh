require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pickupitem"
require "protodef.rpcgen.fire.pb.move.pos"
SAddPickupScreen = {}
SAddPickupScreen.__index = SAddPickupScreen



SAddPickupScreen.PROTOCOL_TYPE = 790445

function SAddPickupScreen.Create()
	print("enter SAddPickupScreen create")
	return SAddPickupScreen:new()
end
function SAddPickupScreen:new()
	local self = {}
	setmetatable(self, SAddPickupScreen)
	self.type = self.PROTOCOL_TYPE
	self.pickuplist = {}

	return self
end
function SAddPickupScreen:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddPickupScreen:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.pickuplist))
	for k,v in ipairs(self.pickuplist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SAddPickupScreen:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_pickuplist=0 ,_os_null_pickuplist
	_os_null_pickuplist, sizeof_pickuplist = _os_: uncompact_uint32(sizeof_pickuplist)
	for k = 1,sizeof_pickuplist do
		----------------unmarshal bean
		self.pickuplist[k]=PickUpItem:new()

		self.pickuplist[k]:unmarshal(_os_)

	end
	return _os_
end

return SAddPickupScreen
