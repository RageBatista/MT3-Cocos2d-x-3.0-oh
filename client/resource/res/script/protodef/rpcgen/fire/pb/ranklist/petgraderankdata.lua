require "utils.tableutil"
PetGradeRankData = {}
PetGradeRankData.__index = PetGradeRankData


function PetGradeRankData:new()
	local self = {}
	setmetatable(self, PetGradeRankData)
	self.roleid = 0
	self.uniquepetid = 0
	self.nickname = "" 
	self.petname = "" 
	self.petgrade = 0
	self.rank = 0
	self.colour = 0
	self.Shape = 0
	return self
end
function PetGradeRankData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int64(self.uniquepetid)
	_os_:marshal_wstring(self.nickname)
	_os_:marshal_wstring(self.petname)
	_os_:marshal_int32(self.petgrade)
	_os_:marshal_int32(self.rank)
	_os_:marshal_int32(self.colour)
	_os_:marshal_int32(self.Shape)
	return _os_
end

function PetGradeRankData:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.uniquepetid = _os_:unmarshal_int64()
	self.nickname = _os_:unmarshal_wstring(self.nickname)
	self.petname = _os_:unmarshal_wstring(self.petname)
	self.petgrade = _os_:unmarshal_int32()
	self.rank = _os_:unmarshal_int32()
	self.colour = _os_:unmarshal_int32()
	self.Shape = _os_:unmarshal_int32()
	return _os_
end

return PetGradeRankData
