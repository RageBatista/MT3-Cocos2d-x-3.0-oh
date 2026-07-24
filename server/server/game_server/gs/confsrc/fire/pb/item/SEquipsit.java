package fire.pb.item;


public class SEquipsit implements mytools.ConvMain.Checkable ,Comparable<SEquipsit>{

	public int compareTo(SEquipsit o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SEquipsit(){
		super();
	}
	public SEquipsit(SEquipsit arg){
		this.id=arg.id ;
		this.buffid=arg.buffid ;
		this.skillid=arg.skillid ;
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
	public String buffid  = null  ;
	
	public String getBuffid(){
		return this.buffid;
	}
	
	public void setBuffid(String v){
		this.buffid=v;
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
	
	
};