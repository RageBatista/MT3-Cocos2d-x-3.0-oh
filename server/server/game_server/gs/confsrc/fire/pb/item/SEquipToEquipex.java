package fire.pb.item;


public class SEquipToEquipex implements mytools.ConvMain.Checkable ,Comparable<SEquipToEquipex>{

	public int compareTo(SEquipToEquipex o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SEquipToEquipex(){
		super();
	}
	public SEquipToEquipex(SEquipToEquipex arg){
		this.id=arg.id ;
		this.needitemid=arg.needitemid ;
		this.needitemcount=arg.needitemcount ;
		this.toitemlist=arg.toitemlist ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
	}
	/**
	 * id
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
	public int needitemid  = 0  ;
	
	public int getNeeditemid(){
		return this.needitemid;
	}
	
	public void setNeeditemid(int v){
		this.needitemid=v;
	}
	
	/**
	 * 
	 */
	public int needitemcount  = 0  ;
	
	public int getNeeditemcount(){
		return this.needitemcount;
	}
	
	public void setNeeditemcount(int v){
		this.needitemcount=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> toitemlist  ;
	
	public java.util.ArrayList<Integer> getToitemlist(){
		return this.toitemlist;
	}
	
	public void setToitemlist(java.util.ArrayList<Integer> v){
		this.toitemlist=v;
	}
	
	
};