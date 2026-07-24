package fire.pb.game;


public class SBenefitCode implements mytools.ConvMain.Checkable ,Comparable<SBenefitCode>{

	public int compareTo(SBenefitCode o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SBenefitCode(){
		super();
	}
	public SBenefitCode(SBenefitCode arg){
		this.id=arg.id ;
		this.code=arg.code ;
		this.itemid=arg.itemid ;
		this.itemnum=arg.itemnum ;
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
	public String code  = null  ;
	
	public String getCode(){
		return this.code;
	}
	
	public void setCode(String v){
		this.code=v;
	}
	
	/**
	 * 
	 */
	public int itemid  = 0  ;
	
	public int getItemid(){
		return this.itemid;
	}
	
	public void setItemid(int v){
		this.itemid=v;
	}
	
	/**
	 * 
	 */
	public int itemnum  = 0  ;
	
	public int getItemnum(){
		return this.itemnum;
	}
	
	public void setItemnum(int v){
		this.itemnum=v;
	}
	
	
};