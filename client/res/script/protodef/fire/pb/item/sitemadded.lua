require "utils.tableutil"
require "protodef.rpcgen.fire.pb.item.itemaddinfo"
SItemAdded = {}
SItemAdded.__index = SItemAdded



SItemAdded.PROTOCOL_TYPE = 787658

function SItemAdded.Create()
	print("enter SItemAdded create")
	return SItemAdded:new()
end
function SItemAdded:new()
	local self = {}
	setmetatable(self, SItemAdded)
	self.type = self.PROTOCOL_TYPE
	self.items = {}

	return self
end
function SItemAdded:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SItemAdded:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.items))
	for k,v in ipairs(self.items) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SItemAdded:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_items=0,_os_null_items
	_os_null_items, sizeof_items = _os_: uncompact_uint32(sizeof_items)
	for k = 1,sizeof_items do
		----------------unmarshal bean
		self.items[k]=ItemAddInfo:new()

		self.items[k]:unmarshal(_os_)

	end
	return _os_
end

return SItemAdded
