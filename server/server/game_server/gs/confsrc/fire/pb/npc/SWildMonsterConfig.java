package fire.pb.npc;


public class SWildMonsterConfig  extends MonsterConfig {

	public int compareTo(SWildMonsterConfig o){
		return this.id-o.id;
	}

	
	public SWildMonsterConfig(MonsterConfig arg){
		super(arg);
	}
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SWildMonsterConfig(){
		super();
	}
	public SWildMonsterConfig(SWildMonsterConfig arg){
		super(arg);
		this.id=arg.id ;
		this.name=arg.name ;
		this.type=arg.type ;
		this.bodytype=arg.bodytype ;
		this.pet=arg.pet ;
		this.colorid=arg.colorid ;
		this.orbinding=arg.orbinding ;
		this.title=arg.title ;
		this.shape=arg.shape ;
		this.randomShapes=arg.randomShapes ;
		this.npctypeid=arg.npctypeid ;
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
		this.initPoint=arg.initPoint ;
		this.initPointAssignType=arg.initPointAssignType ;
		this.addpoint=arg.addpoint ;
		this.attackapt=arg.attackapt ;
		this.defendapt=arg.defendapt ;
		this.phyforceapt=arg.phyforceapt ;
		this.magicapt=arg.magicapt ;
		this.speedapt=arg.speedapt ;
		this.dodgeapt=arg.dodgeapt ;
		this.growrate=arg.growrate ;
		this.healgrow=arg.healgrow ;
		this.ctrlhitgrow=arg.ctrlhitgrow ;
		this.ctrlresistgrow=arg.ctrlresistgrow ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			super.checkValid(objs);
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SWildMonsterConfig.id="+tmprefvalue+",所以不满足条件 SWildMonsterConfig.id < 1");
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
	public int npctypeid  = 0  ;
	
	public int getNpctypeid(){
		return this.npctypeid;
	}
	
	public void setNpctypeid(int v){
		this.npctypeid=v;
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
	public int initPoint  = 0  ;
	
	public int getInitPoint(){
		return this.initPoint;
	}
	
	public void setInitPoint(int v){
		this.initPoint=v;
	}
	
	/**
	 * 
	 */
	public int initPointAssignType  = 0  ;
	
	public int getInitPointAssignType(){
		return this.initPointAssignType;
	}
	
	public void setInitPointAssignType(int v){
		this.initPointAssignType=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> addpoint  ;
	
	public java.util.ArrayList<Integer> getAddpoint(){
		return this.addpoint;
	}
	
	public void setAddpoint(java.util.ArrayList<Integer> v){
		this.addpoint=v;
	}
	
	/**
	 * 
	 */
	public int attackapt  = 0  ;
	
	public int getAttackapt(){
		return this.attackapt;
	}
	
	public void setAttackapt(int v){
		this.attackapt=v;
	}
	
	/**
	 * 
	 */
	public int defendapt  = 0  ;
	
	public int getDefendapt(){
		return this.defendapt;
	}
	
	public void setDefendapt(int v){
		this.defendapt=v;
	}
	
	/**
	 * 
	 */
	public int phyforceapt  = 0  ;
	
	public int getPhyforceapt(){
		return this.phyforceapt;
	}
	
	public void setPhyforceapt(int v){
		this.phyforceapt=v;
	}
	
	/**
	 * 
	 */
	public int magicapt  = 0  ;
	
	public int getMagicapt(){
		return this.magicapt;
	}
	
	public void setMagicapt(int v){
		this.magicapt=v;
	}
	
	/**
	 * 
	 */
	public int speedapt  = 0  ;
	
	public int getSpeedapt(){
		return this.speedapt;
	}
	
	public void setSpeedapt(int v){
		this.speedapt=v;
	}
	
	/**
	 * 
	 */
	public int dodgeapt  = 0  ;
	
	public int getDodgeapt(){
		return this.dodgeapt;
	}
	
	public void setDodgeapt(int v){
		this.dodgeapt=v;
	}
	
	/**
	 * 
	 */
	public int growrate  = 0  ;
	
	public int getGrowrate(){
		return this.growrate;
	}
	
	public void setGrowrate(int v){
		this.growrate=v;
	}
	
	/**
	 * 
	 */
	public int healgrow  = 0  ;
	
	public int getHealgrow(){
		return this.healgrow;
	}
	
	public void setHealgrow(int v){
		this.healgrow=v;
	}
	
	/**
	 * 
	 */
	public int ctrlhitgrow  = 0  ;
	
	public int getCtrlhitgrow(){
		return this.ctrlhitgrow;
	}
	
	public void setCtrlhitgrow(int v){
		this.ctrlhitgrow=v;
	}
	
	/**
	 * 
	 */
	public int ctrlresistgrow  = 0  ;
	
	public int getCtrlresistgrow(){
		return this.ctrlresistgrow;
	}
	
	public void setCtrlresistgrow(int v){
		this.ctrlresistgrow=v;
	}
	
	
};