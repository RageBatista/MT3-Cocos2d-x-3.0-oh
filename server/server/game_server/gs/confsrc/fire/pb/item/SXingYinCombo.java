package fire.pb.item;


public class SXingYinCombo implements mytools.ConvMain.Checkable ,Comparable<SXingYinCombo>{

	public int compareTo(SXingYinCombo o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SXingYinCombo(){
		super();
	}
	public SXingYinCombo(SXingYinCombo arg){
		this.id=arg.id ;
		this.name=arg.name ;
		this.yuancount=arg.yuancount ;
		this.fangcount=arg.fangcount ;
		this.school=arg.school ;
		this.skillid=arg.skillid ;
		this.buffid=arg.buffid ;
		this.buffskillid=arg.buffskillid ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
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
	public int yuancount  = 0  ;
	
	public int getYuancount(){
		return this.yuancount;
	}
	
	public void setYuancount(int v){
		this.yuancount=v;
	}
	
	/**
	 * 
	 */
	public int fangcount  = 0  ;
	
	public int getFangcount(){
		return this.fangcount;
	}
	
	public void setFangcount(int v){
		this.fangcount=v;
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
	public int skillid  = 0  ;
	
	public int getSkillid(){
		return this.skillid;
	}
	
	public void setSkillid(int v){
		this.skillid=v;
	}
	
	/**
	 * 
	 */
	public int buffid  = 0  ;
	
	public int getBuffid(){
		return this.buffid;
	}
	
	public void setBuffid(int v){
		this.buffid=v;
	}
	
	/**
	 * 
	 */
	public int buffskillid  = 0  ;
	
	public int getBuffskillid(){
		return this.buffskillid;
	}
	
	public void setBuffskillid(int v){
		this.buffskillid=v;
	}
	
	
};