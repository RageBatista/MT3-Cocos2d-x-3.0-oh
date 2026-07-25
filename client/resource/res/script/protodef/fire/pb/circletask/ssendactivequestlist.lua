require "utils.tableutil"
require "protodef.rpcgen.fire.pb.circletask.activequestdata"
require "protodef.rpcgen.fire.pb.circletask.rewarditemunit"
SSendActiveQuestList = {}
SSendActiveQuestList.__index = SSendActiveQuestList



SSendActiveQuestList.PROTOCOL_TYPE = 807436

function SSendActiveQuestList.Create()
	print("enter SSendActiveQuestList create")
	return SSendActiveQuestList:new()
end
function SSendActiveQuestList:new()
	local self = {}
	setmetatable(self, SSendActiveQuestList)
	self.type = self.PROTOCOL_TYPE
	self.memberlist = {}

	return self
end
function SSendActiveQuestList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendActiveQuestList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.memberlist))
	for k,v in ipairs(self.memberlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SSendActiveQuestList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_memberlist=0 ,_os_null_memberlist
	_os_null_memberlist, sizeof_memberlist = _os_: uncompact_uint32(sizeof_memberlist)
	for k = 1,sizeof_memberlist do
		----------------unmarshal bean
		self.memberlist[k]=ActiveQuestData:new()

		self.memberlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SSendActiveQuestList
