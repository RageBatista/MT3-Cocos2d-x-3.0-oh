require "utils.tableutil"
require "protodef.rpcgen.fire.pb.skill.liveskill.liveskill"
SRequestLiveSkillList = {}
SRequestLiveSkillList.__index = SRequestLiveSkillList



SRequestLiveSkillList.PROTOCOL_TYPE = 800514

function SRequestLiveSkillList.Create()
	print("enter SRequestLiveSkillList create")
	return SRequestLiveSkillList:new()
end
function SRequestLiveSkillList:new()
	local self = {}
	setmetatable(self, SRequestLiveSkillList)
	self.type = self.PROTOCOL_TYPE
	self.skilllist = {}

	return self
end
function SRequestLiveSkillList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestLiveSkillList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.skilllist))
	for k,v in ipairs(self.skilllist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRequestLiveSkillList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_skilllist=0 ,_os_null_skilllist
	_os_null_skilllist, sizeof_skilllist = _os_: uncompact_uint32(sizeof_skilllist)
	for k = 1,sizeof_skilllist do
		----------------unmarshal bean
		self.skilllist[k]=LiveSkill:new()

		self.skilllist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRequestLiveSkillList
