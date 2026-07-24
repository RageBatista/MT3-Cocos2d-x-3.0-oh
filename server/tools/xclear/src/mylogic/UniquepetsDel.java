package mylogic;


public class UniquepetsDel {
	
	public static void remove(long roleId){
		//宠物仓库
		xbean.Pets pets=xtable.Petdepot.get(roleId);
		if(pets!=null){
			for(xbean.PetInfo info:pets.getPetmap().values()){
				if(info == null){
					continue;
				}
				xtable.Uniquepets.remove(info.getUniqid());
			}
		}
		//pet	宠物
		xbean.Pets pets2=xtable.Pet.get(roleId);
		if(pets2!=null){
			for(xbean.PetInfo info:pets2.getPetmap().values()){
				if(info == null){
					continue;
				}
				xtable.Uniquepets.remove(info.getUniqid());
			}
		}
		xtable.Petdepot.remove(roleId);//petdepot	宠物仓库
		xtable.Pet.remove(roleId);//pet	宠物
	}

}
