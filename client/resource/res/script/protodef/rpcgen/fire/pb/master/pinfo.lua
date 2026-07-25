require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.achive"
require "protodef.rpcgen.fire.pb.master.pbaseinfo"
PInfo = {}
PInfo.__index = PInfo


function PInfo:new()
	local self = {}
	setmetatable(self, PInfo)
	self.prentice = PBaseInfo:new()
	self.achivemap = {}

	return self
end
function PInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.prentice:marshal(_os_) 

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.achivemap))
	for k,v in pairs(self.achivemap) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function PInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.prentice:unmarshal(_os_)

	----------------unmarshal map
	local sizeof_achivemap=0,_os_null_achivemap
	_os_null_achivemap, sizeof_achivemap = _os_: uncompact_uint32(sizeof_achivemap)
	for k = 1,sizeof_achivemap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=Achive:new()

		newvalue:unmarshal(_os_)

		self.achivemap[newkey] = newvalue
	end
	return _os_
end

return PInfo
