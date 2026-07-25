require "utils.tableutil"
CGrabMonthCardReward = {}
CGrabMonthCardReward.__index = CGrabMonthCardReward



CGrabMonthCardReward.PROTOCOL_TYPE = 812689

function CGrabMonthCardReward.Create()
	print("enter CGrabMonthCardReward create")
	return CGrabMonthCardReward:new()
end
function CGrabMonthCardReward:new()
	local self = {}
	setmetatable(self, CGrabMonthCardReward)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.rewarddistribution = {}

	return self
end
function CGrabMonthCardReward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGrabMonthCardReward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.rewarddistribution))
	for k,v in pairs(self.rewarddistribution) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function CGrabMonthCardReward:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_rewarddistribution=0,_os_null_rewarddistribution
	_os_null_rewarddistribution, sizeof_rewarddistribution = _os_: uncompact_uint32(sizeof_rewarddistribution)
	for k = 1,sizeof_rewarddistribution do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.rewarddistribution[newkey] = newvalue
	end
	return _os_
end

return CGrabMonthCardReward
