require "utils.tableutil"
SyncPotentialFruit = {}
SyncPotentialFruit.__index = SyncPotentialFruit



SyncPotentialFruit.PROTOCOL_TYPE = 810500

function SyncPotentialFruit.Create()
	print("enter CChangeSchool create")
	return SyncPotentialFruit:new()
end
function SyncPotentialFruit:new()
	local self = {}
	setmetatable(self, SyncPotentialFruit)
	self.type = self.PROTOCOL_TYPE
	self.locations = {}
	self.props={}
	self.extraprops={}
	return self
end
function SyncPotentialFruit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SyncPotentialFruit:marshal(ostream)

	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:compact_uint32(TableUtil.tablelength(self.locations))
	for k,v in pairs(self.locations) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:compact_uint32(TableUtil.tablelength(self.props))
	for k,v in pairs(self.props) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:compact_uint32(TableUtil.tablelength(self.extraprops))
	for k,v in pairs(self.extraprops) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	return _os_
end

function SyncPotentialFruit:unmarshal(_os_)

	local sizeof_locations=0,_os_null_locations
	_os_null_locations, sizeof_locations = _os_: uncompact_uint32(sizeof_locations)
	for k = 1,sizeof_locations do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.locations[newkey] = newvalue
	end


	local sizeof_props=0,_os_null_props
	_os_null_props, sizeof_props = _os_: uncompact_uint32(sizeof_props)
	for k = 1,sizeof_props do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.props[newkey] = newvalue
	end

	local sizeof_extraprops=0,_os_null_extraprops
	_os_null_extraprops, sizeof_extraprops = _os_: uncompact_uint32(sizeof_extraprops)
	for k = 1,sizeof_extraprops do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.extraprops[newkey] = newvalue
	end
	return _os_
end

return SyncPotentialFruit
