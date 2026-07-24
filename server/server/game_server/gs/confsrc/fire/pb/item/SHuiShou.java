package fire.pb.item;


public class SHuiShou  extends ItemShuXing {

	public int compareTo(SHuiShou o){
		return this.id-o.id;
	}

	
	public SHuiShou(ItemShuXing arg){
		super(arg);
	}
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SHuiShou(){
		super();
	}
	public SHuiShou(SHuiShou arg){
		super(arg);
		this.canhuishou=arg.canhuishou ;
		this.huishouitemid=arg.huishouitemid ;
		this.huishouitemnum=arg.huishouitemnum ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			super.checkValid(objs);
	}
	/**
	 * 
	 */
	public int canhuishou  = 0  ;
	
	public int getCanhuishou(){
		return this.canhuishou;
	}
	
	public void setCanhuishou(int v){
		this.canhuishou=v;
	}
	
	/**
	 * 
	 */
	public int huishouitemid  = 0  ;
	
	public int getHuishouitemid(){
		return this.huishouitemid;
	}
	
	public void setHuishouitemid(int v){
		this.huishouitemid=v;
	}
	
	/**
	 * 
	 */
	public int huishouitemnum  = 0  ;
	
	public int getHuishouitemnum(){
		return this.huishouitemnum;
	}
	
	public void setHuishouitemnum(int v){
		this.huishouitemnum=v;
	}
	
	
};