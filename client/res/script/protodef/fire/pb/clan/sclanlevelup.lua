require "utils.tableutil"
SClanLevelup = {}
SClanLevelup.__index = SClanLevelup



SClanLevelup.PROTOCOL_TYPE = 808473

function SClanLevelup.Create()
	print("enter SClanLevelup create")
	return SClanLevelup:new()
end
function SClanLevelup:new()
	local self = {}
	setmetatable(self, SClanLevelup)
	self.type = self.PROTOCOL_TYPE
	self.change = {}
	self.costmax = {}
	self.money = 0

	return self
end
function SClanLevelup:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SClanLevelup:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.change))
	for k,v in pairs(self.change) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.costmax))
	for k,v in pairs(self.costmax) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.money)
	return _os_
end

function SClanLevelup:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_change=0,_os_null_change
	_os_null_change, sizeof_change = _os_: uncompact_uint32(sizeof_change)
	for k = 1,sizeof_change do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.change[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_costmax=0,_os_null_costmax
	_os_null_costmax, sizeof_costmax = _os_: uncompact_uint32(sizeof_costmax)
	for k = 1,sizeof_costmax do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.costmax[newkey] = newvalue
	end
	self.money = _os_:unmarshal_int32()
	return _os_
end

return SClanLevelup
