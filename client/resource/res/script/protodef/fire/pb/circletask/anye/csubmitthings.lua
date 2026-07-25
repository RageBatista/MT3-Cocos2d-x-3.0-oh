require "utils.tableutil"
require "protodef.rpcgen.fire.pb.circletask.anye.submitthing"
CSubmitThings = {}
CSubmitThings.__index = CSubmitThings



CSubmitThings.PROTOCOL_TYPE = 807455

function CSubmitThings.Create()
	print("enter CSubmitThings create")
	return CSubmitThings:new()
end
function CSubmitThings:new()
	local self = {}
	setmetatable(self, CSubmitThings)
	self.type = self.PROTOCOL_TYPE
	self.taskpos = 0
	self.taskid = 0
	self.taskrole = 0
	self.submittype = 0
	self.things = {}

	return self
end
function CSubmitThings:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSubmitThings:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.taskpos)
	_os_:marshal_int32(self.taskid)
	_os_:marshal_int64(self.taskrole)
	_os_:marshal_int32(self.submittype)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.things))
	for k,v in ipairs(self.things) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function CSubmitThings:unmarshal(_os_)
	self.taskpos = _os_:unmarshal_int32()
	self.taskid = _os_:unmarshal_int32()
	self.taskrole = _os_:unmarshal_int64()
	self.submittype = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_things=0,_os_null_things
	_os_null_things, sizeof_things = _os_: uncompact_uint32(sizeof_things)
	for k = 1,sizeof_things do
		----------------unmarshal bean
		self.things[k]=SubmitThing:new()

		self.things[k]:unmarshal(_os_)

	end
	return _os_
end

return CSubmitThings
