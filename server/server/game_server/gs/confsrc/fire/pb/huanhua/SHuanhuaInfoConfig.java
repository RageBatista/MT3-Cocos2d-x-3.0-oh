package fire.pb.huanhua;


public class SHuanhuaInfoConfig implements mytools.ConvMain.Checkable ,Comparable<SHuanhuaInfoConfig>{

	public int compareTo(SHuanhuaInfoConfig o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SHuanhuaInfoConfig(){
		super();
	}
	public SHuanhuaInfoConfig(SHuanhuaInfoConfig arg){
		this.id=arg.id ;
		this.name=arg.name ;
		this.type=arg.type ;
		this.modelid=arg.modelid ;
		this.headid=arg.headid ;
		this.scale=arg.scale ;
		this.skills=arg.skills ;
		this.specialskills=arg.specialskills ;
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
	public int modelid  = 0  ;
	
	public int getModelid(){
		return this.modelid;
	}
	
	public void setModelid(int v){
		this.modelid=v;
	}
	
	/**
	 * 
	 */
	public int headid  = 0  ;
	
	public int getHeadid(){
		return this.headid;
	}
	
	public void setHeadid(int v){
		this.headid=v;
	}
	
	/**
	 * 
	 */
	public double scale  = 0.0  ;
	
	public double getScale(){
		return this.scale;
	}
	
	public void setScale(double v){
		this.scale=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> skills  ;
	
	public java.util.ArrayList<Integer> getSkills(){
		return this.skills;
	}
	
	public void setSkills(java.util.ArrayList<Integer> v){
		this.skills=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> specialskills  ;
	
	public java.util.ArrayList<Integer> getSpecialskills(){
		return this.specialskills;
	}
	
	public void setSpecialskills(java.util.ArrayList<Integer> v){
		this.specialskills=v;
	}
	
	
};