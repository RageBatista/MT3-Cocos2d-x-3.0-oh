package fire.pb.item;


public class SFenJie  extends ItemShuXing {

	public int compareTo(SFenJie o){
		return this.id-o.id;
	}

	
	public SFenJie(ItemShuXing arg){
		super(arg);
	}
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SFenJie(){
		super();
	}
	public SFenJie(SFenJie arg){
		super(arg);
		this.canfenjie=arg.canfenjie ;
		this.returnitemid=arg.returnitemid ;
		this.returnitemnum=arg.returnitemnum ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			super.checkValid(objs);
	}
	/**
	 * 
	 */
	public int canfenjie  = 0  ;
	
	public int getCanfenjie(){
		return this.canfenjie;
	}
	
	public void setCanfenjie(int v){
		this.canfenjie=v;
	}
	
	/**
	 * 
	 */
	public int returnitemid  = 0  ;
	
	public int getReturnitemid(){
		return this.returnitemid;
	}
	
	public void setReturnitemid(int v){
		this.returnitemid=v;
	}
	
	/**
	 * 
	 */
	public int returnitemnum  = 0  ;
	
	public int getReturnitemnum(){
		return this.returnitemnum;
	}
	
	public void setReturnitemnum(int v){
		this.returnitemnum=v;
	}
	
	
};