require "utils.tableutil"
SAskQuestion = {
	QUEST = 1,
	INSTANCE_ZONE = 2,
	FRIEND_NPC_CHAT = 3,
	SPECIALQUEST_ANSWER = 5,
	GUILD_ANSWER = 7,
	ACTIVITY_ANSWER = 8
}
SAskQuestion.__index = SAskQuestion



SAskQuestion.PROTOCOL_TYPE = 795520

function SAskQuestion.Create()
	print("enter SAskQuestion create")
	return SAskQuestion:new()
end
function SAskQuestion:new()
	local self = {}
	setmetatable(self, SAskQuestion)
	self.type = self.PROTOCOL_TYPE
	self.lastresult = 0
	self.questionid = 0
	self.questiontype = 0
	self.npckey = 0
	self.xiangguanid = 0
	self.lasttime = 0
	self.cur = 0
	self.num = 0
	self.totalexp = 0
	self.totalmoney = 0
	self.helptimes = 0
	self.grab = 0
	self.rightanswer = {}

	return self
end
function SAskQuestion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAskQuestion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.lastresult)
	_os_:marshal_int32(self.questionid)
	_os_:marshal_int32(self.questiontype)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.xiangguanid)
	_os_:marshal_int32(self.lasttime)
	_os_:marshal_int32(self.cur)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.totalexp)
	_os_:marshal_int32(self.totalmoney)
	_os_:marshal_int32(self.helptimes)
	_os_:marshal_int32(self.grab)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rightanswer))
	for k,v in ipairs(self.rightanswer) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SAskQuestion:unmarshal(_os_)
	self.lastresult = _os_:unmarshal_char()
	self.questionid = _os_:unmarshal_int32()
	self.questiontype = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.xiangguanid = _os_:unmarshal_int32()
	self.lasttime = _os_:unmarshal_int32()
	self.cur = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.totalexp = _os_:unmarshal_int32()
	self.totalmoney = _os_:unmarshal_int32()
	self.helptimes = _os_:unmarshal_int32()
	self.grab = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_rightanswer=0 ,_os_null_rightanswer
	_os_null_rightanswer, sizeof_rightanswer = _os_: uncompact_uint32(sizeof_rightanswer)
	for k = 1,sizeof_rightanswer do
		self.rightanswer[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SAskQuestion
