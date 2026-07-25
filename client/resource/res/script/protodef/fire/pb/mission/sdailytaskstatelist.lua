require "utils.tableutil"
require "protodef.rpcgen.fire.pb.mission.dailytaskstate"
SDailyTaskStateList = {}
SDailyTaskStateList.__index = SDailyTaskStateList



SDailyTaskStateList.PROTOCOL_TYPE = 805520

function SDailyTaskStateList.Create()
	print("enter SDailyTaskStateList create")
	return SDailyTaskStateList:new()
end
function SDailyTaskStateList:new()
	local self = {}
	setmetatable(self, SDailyTaskStateList)
	self.type = self.PROTOCOL_TYPE
	self.notifylist = {}

	return self
end
function SDailyTaskStateList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDailyTaskStateList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.notifylist))
	for k,v in ipairs(self.notifylist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SDailyTaskStateList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_notifylist=0 ,_os_null_notifylist
	_os_null_notifylist, sizeof_notifylist = _os_: uncompact_uint32(sizeof_notifylist)
	for k = 1,sizeof_notifylist do
		----------------unmarshal bean
		self.notifylist[k]=DailyTaskState:new()

		self.notifylist[k]:unmarshal(_os_)

	end
	return _os_
end

return SDailyTaskStateList
