package fire.pb.npc;


public class SMonsterConfig  extends MonsterExtraAttrConfig {

	public int compareTo(SMonsterConfig o){
		return this.id-o.id;
	}

	
	public SMonsterConfig(MonsterExtraAttrConfig arg){
		super(arg);
	}
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SMonsterConfig(){
		super();
	}
	public SMonsterConfig(SMonsterConfig arg){
		super(arg);
		this.id=arg.id ;
		this.name=arg.name ;
		this.type=arg.type ;
		this.pet=arg.pet ;
		this.colorid=arg.colorid ;
		this.bodytype=arg.bodytype ;
		this.orbinding=arg.orbinding ;
		this.title=arg.title ;
		this.shape=arg.shape ;
		this.shape=arg.shape ;
		this.randomShapes=arg.randomShapes ;
		this.daodi=arg.daodi ;
		this.race=arg.race ;
		this.school=arg.school ;
		this.levelType=arg.levelType ;
		this.level=arg.level ;
		this.canCatch=arg.canCatch ;
		this.catchRate=arg.catchRate ;
		this.runRate=arg.runRate ;
		this.skills=arg.skills ;
		this.aiIds=arg.aiIds ;
		this.immunebuffid=arg.immunebuffid ;
		this.daodi=arg.daodi ;
		this.hpAttackFactor=arg.hpAttackFactor ;
		this.hpFactor=arg.hpFactor ;
		this.hpConstant=arg.hpConstant ;
		this.DefaultBattleEp=arg.DefaultBattleEp ;
		this.MaxSp=arg.MaxSp ;
		this.DefaultBattleSp=arg.DefaultBattleSp ;
		this.hpMaxAttackFactor=arg.hpMaxAttackFactor ;
		this.hpMaxFactor=arg.hpMaxFactor ;
		this.hpMaxConstant=arg.hpMaxConstant ;
		this.mpminFactor=arg.mpminFactor ;
		this.mpminConstant=arg.mpminConstant ;
		this.mpMaxFactor=arg.mpMaxFactor ;
		this.mpMaxConstant=arg.mpMaxConstant ;
		this.attackFactor=arg.attackFactor ;
		this.attackConstant=arg.attackConstant ;
		this.defFactor=arg.defFactor ;
		this.defConstant=arg.defConstant ;
		this.magicattFactor=arg.magicattFactor ;
		this.magicattConstant=arg.magicattConstant ;
		this.magicDefFactor=arg.magicDefFactor ;
		this.magicDefConstant=arg.magicDefConstant ;
		this.attallFactor=arg.attallFactor ;
		this.attallConstant=arg.attallConstant ;
		this.speedFactor=arg.speedFactor ;
		this.speedConstant=arg.speedConstant ;
		this.medicalFactor=arg.medicalFactor ;
		this.medicalConstant=arg.medicalConstant ;
		this.sealhitFactor=arg.sealhitFactor ;
		this.sealhitConstant=arg.sealhitConstant ;
		this.unsealFactor=arg.unsealFactor ;
		this.unsealConstant=arg.unsealConstant ;
		this.skills=arg.skills ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			super.checkValid(objs);
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SMonsterConfig.id="+tmprefvalue+",所以不满足条件 SMonsterConfig.id < 1");
			}while(false);
	}
	/**
	 * 
	 */
	public int id  = 0  ;
	
	public int getId(){
		return this.id;
	}
	
	public void setId(int v){
		this.id=v;
	}
	
	/**
	 * 
	 */
	public String name  = null  ;
	
	public String getName(){
		return this.name;
	}
	
	public void setName(String v){
		this.name=v;
	}
	
	/**
	 * 
	 */
	public int type  = 0  ;
	
	public int getType(){
		return this.type;
	}
	
	public void setType(int v){
		this.type=v;
	}
	
	/**
	 * 
	 */
	public int pet  = 0  ;
	
	public int getPet(){
		return this.pet;
	}
	
	public void setPet(int v){
		this.pet=v;
	}
	
	/**
	 * 
	 */
	public int colorid  = 0  ;
	
	public int getColorid(){
		return this.colorid;
	}
	
	public void setColorid(int v){
		this.colorid=v;
	}
	
	/**
	 * 
	 */
	public double bodytype  = 0.0  ;
	
	public double getBodytype(){
		return this.bodytype;
	}
	
	public void setBodytype(double v){
		this.bodytype=v;
	}
	
	/**
	 * 
	 */
	public int orbinding  = 0  ;
	
	public int getOrbinding(){
		return this.orbinding;
	}
	
	public void setOrbinding(int v){
		this.orbinding=v;
	}
	
	/**
	 * 
	 */
	public String title  = null  ;
	
	public String getTitle(){
		return this.title;
	}
	
	public void setTitle(String v){
		this.title=v;
	}
	
	/**
	 * 
	 */
	public int shape  = 0  ;
	
	public int getShape(){
		return this.shape;
	}
	
	public void setShape(int v){
		this.shape=v;
	}
	
	/**
	 * 
	 */
	public int shape  = 0  ;
	
	public int getShape(){
		return this.shape;
	}
	
	public void setShape(int v){
		this.shape=v;
	}
	
	/**
	 * 
	 */
	public String randomShapes  = null  ;
	
	public String getRandomShapes(){
		return this.randomShapes;
	}
	
	public void setRandomShapes(String v){
		this.randomShapes=v;
	}
	
	/**
	 * 
	 */
	public int daodi  = 0  ;
	
	public int getDaodi(){
		return this.daodi;
	}
	
	public void setDaodi(int v){
		this.daodi=v;
	}
	
	/**
	 * 
	 */
	public int race  = 0  ;
	
	public int getRace(){
		return this.race;
	}
	
	public void setRace(int v){
		this.race=v;
	}
	
	/**
	 * 
	 */
	public int school  = 0  ;
	
	public int getSchool(){
		return this.school;
	}
	
	public void setSchool(int v){
		this.school=v;
	}
	
	/**
	 * 
	 */
	public int levelType  = 0  ;
	
	public int getLevelType(){
		return this.levelType;
	}
	
	public void setLevelType(int v){
		this.levelType=v;
	}
	
	/**
	 * 
	 */
	public int level  = 0  ;
	
	public int getLevel(){
		return this.level;
	}
	
	public void setLevel(int v){
		this.level=v;
	}
	
	/**
	 * 
	 */
	public boolean canCatch  = false  ;
	
	public boolean getCanCatch(){
		return this.canCatch;
	}
	
	public void setCanCatch(boolean v){
		this.canCatch=v;
	}
	
	/**
	 * 
	 */
	public int catchRate  = 0  ;
	
	public int getCatchRate(){
		return this.catchRate;
	}
	
	public void setCatchRate(int v){
		this.catchRate=v;
	}
	
	/**
	 * 
	 */
	public int runRate  = 0  ;
	
	public int getRunRate(){
		return this.runRate;
	}
	
	public void setRunRate(int v){
		this.runRate=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<fire.pb.npc.SMonsterSkill> skills  ;
	
	public java.util.ArrayList<fire.pb.npc.SMonsterSkill> getSkills(){
		return this.skills;
	}
	
	public void setSkills(java.util.ArrayList<fire.pb.npc.SMonsterSkill> v){
		this.skills=v;
	}
	
	/**
	 * 
	 */
	public String aiIds  = null  ;
	
	public String getAiIds(){
		return this.aiIds;
	}
	
	public void setAiIds(String v){
		this.aiIds=v;
	}
	
	/**
	 * 
	 */
	public String immunebuffid  = null  ;
	
	public String getImmunebuffid(){
		return this.immunebuffid;
	}
	
	public void setImmunebuffid(String v){
		this.immunebuffid=v;
	}
	
	/**
	 * 
	 */
	public int daodi  = 0  ;
	
	public int getDaodi(){
		return this.daodi;
	}
	
	public void setDaodi(int v){
		this.daodi=v;
	}
	
	/**
	 * 
	 */
	public double hpAttackFactor  = 0.0  ;
	
	public double getHpAttackFactor(){
		return this.hpAttackFactor;
	}
	
	public void setHpAttackFactor(double v){
		this.hpAttackFactor=v;
	}
	
	/**
	 * 
	 */
	public double hpFactor  = 0.0  ;
	
	public double getHpFactor(){
		return this.hpFactor;
	}
	
	public void setHpFactor(double v){
		this.hpFactor=v;
	}
	
	/**
	 * 
	 */
	public double hpConstant  = 0.0  ;
	
	public double getHpConstant(){
		return this.hpConstant;
	}
	
	public void setHpConstant(double v){
		this.hpConstant=v;
	}
	
	/**
	 * 
	 */
	public int DefaultBattleEp  = 0  ;
	
	public int getDefaultBattleEp(){
		return this.DefaultBattleEp;
	}
	
	public void setDefaultBattleEp(int v){
		this.DefaultBattleEp=v;
	}
	
	/**
	 * 
	 */
	public int MaxSp  = 0  ;
	
	public int getMaxSp(){
		return this.MaxSp;
	}
	
	public void setMaxSp(int v){
		this.MaxSp=v;
	}
	
	/**
	 * 
	 */
	public int DefaultBattleSp  = 0  ;
	
	public int getDefaultBattleSp(){
		return this.DefaultBattleSp;
	}
	
	public void setDefaultBattleSp(int v){
		this.DefaultBattleSp=v;
	}
	
	/**
	 * 
	 */
	public double hpMaxAttackFactor  = 0.0  ;
	
	public double getHpMaxAttackFactor(){
		return this.hpMaxAttackFactor;
	}
	
	public void setHpMaxAttackFactor(double v){
		this.hpMaxAttackFactor=v;
	}
	
	/**
	 * 
	 */
	public double hpMaxFactor  = 0.0  ;
	
	public double getHpMaxFactor(){
		return this.hpMaxFactor;
	}
	
	public void setHpMaxFactor(double v){
		this.hpMaxFactor=v;
	}
	
	/**
	 * 
	 */
	public double hpMaxConstant  = 0.0  ;
	
	public double getHpMaxConstant(){
		return this.hpMaxConstant;
	}
	
	public void setHpMaxConstant(double v){
		this.hpMaxConstant=v;
	}
	
	/**
	 * 
	 */
	public double mpminFactor  = 0.0  ;
	
	public double getMpminFactor(){
		return this.mpminFactor;
	}
	
	public void setMpminFactor(double v){
		this.mpminFactor=v;
	}
	
	/**
	 * 
	 */
	public double mpminConstant  = 0.0  ;
	
	public double getMpminConstant(){
		return this.mpminConstant;
	}
	
	public void setMpminConstant(double v){
		this.mpminConstant=v;
	}
	
	/**
	 * 
	 */
	public double mpMaxFactor  = 0.0  ;
	
	public double getMpMaxFactor(){
		return this.mpMaxFactor;
	}
	
	public void setMpMaxFactor(double v){
		this.mpMaxFactor=v;
	}
	
	/**
	 * 
	 */
	public double mpMaxConstant  = 0.0  ;
	
	public double getMpMaxConstant(){
		return this.mpMaxConstant;
	}
	
	public void setMpMaxConstant(double v){
		this.mpMaxConstant=v;
	}
	
	/**
	 * 
	 */
	public double attackFactor  = 0.0  ;
	
	public double getAttackFactor(){
		return this.attackFactor;
	}
	
	public void setAttackFactor(double v){
		this.attackFactor=v;
	}
	
	/**
	 * 
	 */
	public double attackConstant  = 0.0  ;
	
	public double getAttackConstant(){
		return this.attackConstant;
	}
	
	public void setAttackConstant(double v){
		this.attackConstant=v;
	}
	
	/**
	 * 
	 */
	public double defFactor  = 0.0  ;
	
	public double getDefFactor(){
		return this.defFactor;
	}
	
	public void setDefFactor(double v){
		this.defFactor=v;
	}
	
	/**
	 * 
	 */
	public double defConstant  = 0.0  ;
	
	public double getDefConstant(){
		return this.defConstant;
	}
	
	public void setDefConstant(double v){
		this.defConstant=v;
	}
	
	/**
	 * 
	 */
	public double magicattFactor  = 0.0  ;
	
	public double getMagicattFactor(){
		return this.magicattFactor;
	}
	
	public void setMagicattFactor(double v){
		this.magicattFactor=v;
	}
	
	/**
	 * 
	 */
	public double magicattConstant  = 0.0  ;
	
	public double getMagicattConstant(){
		return this.magicattConstant;
	}
	
	public void setMagicattConstant(double v){
		this.magicattConstant=v;
	}
	
	/**
	 * 
	 */
	public double magicDefFactor  = 0.0  ;
	
	public double getMagicDefFactor(){
		return this.magicDefFactor;
	}
	
	public void setMagicDefFactor(double v){
		this.magicDefFactor=v;
	}
	
	/**
	 * 
	 */
	public double magicDefConstant  = 0.0  ;
	
	public double getMagicDefConstant(){
		return this.magicDefConstant;
	}
	
	public void setMagicDefConstant(double v){
		this.magicDefConstant=v;
	}
	
	/**
	 * 
	 */
	public double attallFactor  = 0.0  ;
	
	public double getAttallFactor(){
		return this.attallFactor;
	}
	
	public void setAttallFactor(double v){
		this.attallFactor=v;
	}
	
	/**
	 * 
	 */
	public double attallConstant  = 0.0  ;
	
	public double getAttallConstant(){
		return this.attallConstant;
	}
	
	public void setAttallConstant(double v){
		this.attallConstant=v;
	}
	
	/**
	 * 
	 */
	public double speedFactor  = 0.0  ;
	
	public double getSpeedFactor(){
		return this.speedFactor;
	}
	
	public void setSpeedFactor(double v){
		this.speedFactor=v;
	}
	
	/**
	 * 
	 */
	public double speedConstant  = 0.0  ;
	
	public double getSpeedConstant(){
		return this.speedConstant;
	}
	
	public void setSpeedConstant(double v){
		this.speedConstant=v;
	}
	
	/**
	 * 
	 */
	public double medicalFactor  = 0.0  ;
	
	public double getMedicalFactor(){
		return this.medicalFactor;
	}
	
	public void setMedicalFactor(double v){
		this.medicalFactor=v;
	}
	
	/**
	 * 
	 */
	public double medicalConstant  = 0.0  ;
	
	public double getMedicalConstant(){
		return this.medicalConstant;
	}
	
	public void setMedicalConstant(double v){
		this.medicalConstant=v;
	}
	
	/**
	 * 
	 */
	public double sealhitFactor  = 0.0  ;
	
	public double getSealhitFactor(){
		return this.sealhitFactor;
	}
	
	public void setSealhitFactor(double v){
		this.sealhitFactor=v;
	}
	
	/**
	 * 
	 */
	public double sealhitConstant  = 0.0  ;
	
	public double getSealhitConstant(){
		return this.sealhitConstant;
	}
	
	public void setSealhitConstant(double v){
		this.sealhitConstant=v;
	}
	
	/**
	 * 
	 */
	public double unsealFactor  = 0.0  ;
	
	public double getUnsealFactor(){
		return this.unsealFactor;
	}
	
	public void setUnsealFactor(double v){
		this.unsealFactor=v;
	}
	
	/**
	 * 
	 */
	public double unsealConstant  = 0.0  ;
	
	public double getUnsealConstant(){
		return this.unsealConstant;
	}
	
	public void setUnsealConstant(double v){
		this.unsealConstant=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<fire.pb.npc.SMonsterSkill> skills  ;
	
	public java.util.ArrayList<fire.pb.npc.SMonsterSkill> getSkills(){
		return this.skills;
	}
	
	public void setSkills(java.util.ArrayList<fire.pb.npc.SMonsterSkill> v){
		this.skills=v;
	}
	
	
};