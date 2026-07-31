require "utils.tableutil"
require "protodef.rpcgen.fire.pb.school.candidateinfo"
SSendCandidates = {}
SSendCandidates.__index = SSendCandidates



SSendCandidates.PROTOCOL_TYPE = 810434

function SSendCandidates.Create()
	print("enter SSendCandidates create")
	return SSendCandidates:new()
end
function SSendCandidates:new()
	local self = {}
	setmetatable(self, SSendCandidates)
	self.type = self.PROTOCOL_TYPE
	self.alreadyvote = 0
	self.candidatelist = {}
	self.shouxikey = 0

	return self
end
function SSendCandidates:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendCandidates:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.alreadyvote)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.candidatelist))
	for k,v in ipairs(self.candidatelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int64(self.shouxikey)
	return _os_
end

function SSendCandidates:unmarshal(_os_)
	self.alreadyvote = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_candidatelist=0,_os_null_candidatelist
	_os_null_candidatelist, sizeof_candidatelist = _os_: uncompact_uint32(sizeof_candidatelist)
	for k = 1,sizeof_candidatelist do
		----------------unmarshal bean
		self.candidatelist[k]=CandidateInfo:new()

		self.candidatelist[k]:unmarshal(_os_)

	end
	self.shouxikey = _os_:unmarshal_int64()
	return _os_
end

return SSendCandidates
