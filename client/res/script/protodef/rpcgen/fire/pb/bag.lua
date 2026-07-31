require "utils.tableutil"
require "protodef.rpcgen.fire.pb.item"
Bag = {}
Bag.__index = Bag


function Bag:new()
	local self = {}
	setmetatable(self, Bag)
	self.currency = {}
	self.capacity = 0
	self.items = {}

	return self
end
function Bag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.currency))
	for k,v in pairs(self.currency) do
		_os_:marshal_char(k)
		_os_:marshal_int64(v)
	end

	_os_:marshal_int32(self.capacity)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.items))
	for k,v in ipairs(self.items) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function Bag:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_currency=0,_os_null_currency
	_os_null_currency, sizeof_currency = _os_: uncompact_uint32(sizeof_currency)
	for k = 1,sizeof_currency do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int64()
		self.currency[newkey] = newvalue
	end
	self.capacity = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_items=0,_os_null_items
	_os_null_items, sizeof_items = _os_: uncompact_uint32(sizeof_items)
	for k = 1,sizeof_items do
		----------------unmarshal bean
		self.items[k]=Item:new()

		self.items[k]:unmarshal(_os_)

	end
	return _os_
end

return Bag
