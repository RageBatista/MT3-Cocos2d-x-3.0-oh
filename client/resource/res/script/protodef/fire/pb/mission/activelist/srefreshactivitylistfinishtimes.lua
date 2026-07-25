require "utils.tableutil"
require "protodef.rpcgen.fire.pb.mission.activelist.simpleactivityinfo"
SRefreshActivityListFinishTimes = {}
SRefreshActivityListFinishTimes.__index = SRefreshActivityListFinishTimes



SRefreshActivityListFinishTimes.PROTOCOL_TYPE = 805485

function SRefreshActivityListFinishTimes.Create()
	print("enter SRefreshActivityListFinishTimes create")
	return SRefreshActivityListFinishTimes:new()
end
function SRefreshActivityListFinishTimes:new()
	local self = {}
	setmetatable(self, SRefreshActivityListFinishTimes)
	self.type = self.PROTOCOL_TYPE
	self.activities = {}
	self.activevalue = 0
	self.chests = {}
	self.recommend = 0
	self.closeids = {}

	return self
end
function SRefreshActivityListFinishTimes:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshActivityListFinishTimes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.activities))
	for k,v in pairs(self.activities) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.activevalue)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.chests))
	for k,v in pairs(self.chests) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.recommend)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.closeids))
	for k,v in ipairs(self.closeids) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SRefreshActivityListFinishTimes:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_activities=0,_os_null_activities
	_os_null_activities, sizeof_activities = _os_: uncompact_uint32(sizeof_activities)
	for k = 1,sizeof_activities do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=SimpleActivityInfo:new()

		newvalue:unmarshal(_os_)

		self.activities[newkey] = newvalue
	end
	self.activevalue = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_chests=0,_os_null_chests
	_os_null_chests, sizeof_chests = _os_: uncompact_uint32(sizeof_chests)
	for k = 1,sizeof_chests do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.chests[newkey] = newvalue
	end
	self.recommend = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_closeids=0 ,_os_null_closeids
	_os_null_closeids, sizeof_closeids = _os_: uncompact_uint32(sizeof_closeids)
	for k = 1,sizeof_closeids do
		self.closeids[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SRefreshActivityListFinishTimes
