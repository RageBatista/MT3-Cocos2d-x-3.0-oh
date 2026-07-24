package fire.pb.huanhua;


public class SHuanhuaInheritCost implements mytools.ConvMain.Checkable ,Comparable<SHuanhuaInheritCost>{

	public int compareTo(SHuanhuaInheritCost o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SHuanhuaInheritCost(){
		super();
	}
	public SHuanhuaInheritCost(SHuanhuaInheritCost arg){
		this.id=arg.id ;
		this.skillid=arg.skillid ;
		this.level=arg.level ;
		this.makecards=arg.makecards ;
		this.costitem=arg.costitem ;
		this.costnum=arg.costnum ;
		this.desc=arg.desc ;
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
	public java.util.ArrayList<Integer> makecards  ;
	
	public java.util.ArrayList<Integer> getMakecards(){
		return this.makecards;
	}
	
	public void setMakecards(java.util.ArrayList<Integer> v){
		this.makecards=v;
	}
	
	/**
	 * 
	 */
	public int costitem  = 0  ;
	
	public int getCostitem(){
		return this.costitem;
	}
	
	public void setCostitem(int v){
		this.costitem=v;
	}
	
	/**
	 * 
	 */
	public int costnum  = 0  ;
	
	public int getCostnum(){
		return this.costnum;
	}
	
	public void setCostnum(int v){
		this.costnum=v;
	}
	
	/**
	 * 
	 */
	public String desc  = null  ;
	
	public String getDesc(){
		return this.desc;
	}
	
	public void setDesc(String v){
		this.desc=v;
	}
	
	
};