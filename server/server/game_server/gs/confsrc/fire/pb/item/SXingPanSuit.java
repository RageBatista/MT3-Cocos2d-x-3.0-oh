package fire.pb.item;


public class SXingPanSuit implements mytools.ConvMain.Checkable ,Comparable<SXingPanSuit>{

	public int compareTo(SXingPanSuit o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SXingPanSuit(){
		super();
	}
	public SXingPanSuit(SXingPanSuit arg){
		this.id=arg.id ;
		this.name=arg.name ;
		this.procount=arg.procount ;
		this.school=arg.school ;
		this.skillid=arg.skillid ;
		this.buffid=arg.buffid ;
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
	public int procount  = 0  ;
	
	public int getProcount(){
		return this.procount;
	}
	
	public void setProcount(int v){
		this.procount=v;
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
	
	
};