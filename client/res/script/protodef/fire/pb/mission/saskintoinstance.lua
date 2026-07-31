require "utils.tableutil"
SAskIntoInstance = {}
SAskIntoInstance.__index = SAskIntoInstance



SAskIntoInstance.PROTOCOL_TYPE = 805538

function SAskIntoInstance.Create()
	print("enter SAskIntoInstance create")
	return SAskIntoInstance:new()
end
function SAskIntoInstance:new()
	local self = {}
	setmetatable(self, SAskIntoInstance)
	self.type = self.PROTOCOL_TYPE
	self.msgid = 0
	self.teamleadername = "" 
	self.awardtimes = 0
	self.step = 0
	self.tlstep = 0
	self.mystep = 0
	self.allstep = 0
	self.steplist = {}
	self.insttype = 0
	self.autoenter = 0

	return self
end
function SAskIntoInstance:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAskIntoInstance:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.msgid)
	_os_:marshal_wstring(self.teamleadername)
	_os_:marshal_int32(self.awardtimes)
	_os_:marshal_int32(self.step)
	_os_:marshal_int32(self.tlstep)
	_os_:marshal_int32(self.mystep)
	_os_:marshal_int32(self.allstep)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.steplist))
	for k,v in ipairs(self.steplist) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.insttype)
	_os_:marshal_short(self.autoenter)
	return _os_
end

function SAskIntoInstance:unmarshal(_os_)
	self.msgid = _os_:unmarshal_int32()
	self.teamleadername = _os_:unmarshal_wstring(self.teamleadername)
	self.awardtimes = _os_:unmarshal_int32()
	self.step = _os_:unmarshal_int32()
	self.tlstep = _os_:unmarshal_int32()
	self.mystep = _os_:unmarshal_int32()
	self.allstep = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_steplist=0 ,_os_null_steplist
	_os_null_steplist, sizeof_steplist = _os_: uncompact_uint32(sizeof_steplist)
	for k = 1,sizeof_steplist do
		self.steplist[k] = _os_:unmarshal_int32()
	end
	self.insttype = _os_:unmarshal_int32()
	self.autoenter = _os_:unmarshal_short()
	return _os_
end

return SAskIntoInstance
