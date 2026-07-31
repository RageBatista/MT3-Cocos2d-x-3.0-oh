require "utils.tableutil"
PetError = {
	UnkownError = -1,
	KeyNotFound = -2,
	PetcolumnFull = -3,
	WrongDstCol = -4,
	ShowPetCantMoveErr = -5,
	FightPetCantMoveErr = -6,
	PetNameOverLen = -7,
	PetNameShotLen = -8,
	PetNameInvalid = -9,
	ShowPetCantFree = -10,
	FightPetCantFree = -11,
	WrongFreeCode = -12
}
PetError.__index = PetError


function PetError:new()
	local self = {}
	setmetatable(self, PetError)
	return self
end
function PetError:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function PetError:unmarshal(_os_)
	return _os_
end

return PetError
