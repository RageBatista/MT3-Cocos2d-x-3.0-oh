require "utils.tableutil"
SQueryFestivalData = {}
SQueryFestivalData.__index = SQueryFestivalData



SQueryFestivalData.PROTOCOL_TYPE = 810536

function SQueryFestivalData.Create()
	print("enter SQueryFestivalData create")
	return SQueryFestivalData:new()
end
function SQueryFestivalData:new()
	local self = {}
	setmetatable(self, SQueryFestivalData)
	self.type = self.PROTOCOL_TYPE
	self.rewards = {}

	return self
end
function SQueryFestivalData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQueryFestivalData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.rewards))
	for k,v in ipairs(self.rewards) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SQueryFestivalData:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_rewards=0,_os_null_rewards
	_os_null_rewards, sizeof_rewards = _os_: uncompact_uint32(sizeof_rewards)
	for k = 1,sizeof_rewards do
		self.rewards[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SQueryFestivalData
