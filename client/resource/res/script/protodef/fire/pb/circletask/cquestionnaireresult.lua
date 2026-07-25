require "utils.tableutil"
CQuestionnaireResult = {}
CQuestionnaireResult.__index = CQuestionnaireResult



CQuestionnaireResult.PROTOCOL_TYPE = 807444

function CQuestionnaireResult.Create()
	print("enter CQuestionnaireResult create")
	return CQuestionnaireResult:new()
end
function CQuestionnaireResult:new()
	local self = {}
	setmetatable(self, CQuestionnaireResult)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.step = 0
	self.result = {}

	return self
end
function CQuestionnaireResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQuestionnaireResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.step)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.result))
	for k,v in ipairs(self.result) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function CQuestionnaireResult:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.step = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_result=0,_os_null_result
	_os_null_result, sizeof_result = _os_: uncompact_uint32(sizeof_result)
	for k = 1,sizeof_result do
		self.result[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return CQuestionnaireResult
