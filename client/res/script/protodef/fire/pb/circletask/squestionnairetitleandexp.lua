require "utils.tableutil"
SQuestionnaireTitleAndExp = {}
SQuestionnaireTitleAndExp.__index = SQuestionnaireTitleAndExp



SQuestionnaireTitleAndExp.PROTOCOL_TYPE = 807445

function SQuestionnaireTitleAndExp.Create()
	print("enter SQuestionnaireTitleAndExp create")
	return SQuestionnaireTitleAndExp:new()
end
function SQuestionnaireTitleAndExp:new()
	local self = {}
	setmetatable(self, SQuestionnaireTitleAndExp)
	self.type = self.PROTOCOL_TYPE
	self.title = 0
	self.exp = 0

	return self
end
function SQuestionnaireTitleAndExp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQuestionnaireTitleAndExp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.title)
	_os_:marshal_int64(self.exp)
	return _os_
end

function SQuestionnaireTitleAndExp:unmarshal(_os_)
	self.title = _os_:unmarshal_int32()
	self.exp = _os_:unmarshal_int64()
	return _os_
end

return SQuestionnaireTitleAndExp
