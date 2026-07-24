package fire.pb.item;


public class SFumoInfo implements mytools.ConvMain.Checkable ,Comparable<SFumoInfo>{

	public int compareTo(SFumoInfo o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SFumoInfo(){
		super();
	}
	public SFumoInfo(SFumoInfo arg){
		this.id=arg.id ;
		this.skilltype=arg.skilltype ;
		this.probability=arg.probability ;
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
	public int skilltype  = 0  ;
	
	public int getSkilltype(){
		return this.skilltype;
	}
	
	public void setSkilltype(int v){
		this.skilltype=v;
	}
	
	/**
	 * 
	 */
	public double probability  = 0.0  ;
	
	public double getProbability(){
		return this.probability;
	}
	
	public void setProbability(double v){
		this.probability=v;
	}
	
	
};