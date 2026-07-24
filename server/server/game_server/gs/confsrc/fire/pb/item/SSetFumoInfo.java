package fire.pb.item;


public class SSetFumoInfo implements mytools.ConvMain.Checkable ,Comparable<SSetFumoInfo>{

	public int compareTo(SSetFumoInfo o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SSetFumoInfo(){
		super();
	}
	public SSetFumoInfo(SSetFumoInfo arg){
		this.id=arg.id ;
		this.skilltype=arg.skilltype ;
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