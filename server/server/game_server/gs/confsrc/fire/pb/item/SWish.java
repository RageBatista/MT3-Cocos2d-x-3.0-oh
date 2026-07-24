package fire.pb.item;


public class SWish implements mytools.ConvMain.Checkable ,Comparable<SWish>{

	public int compareTo(SWish o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SWish(){
		super();
	}
	public SWish(SWish arg){
		this.id=arg.id ;
		this.itemid=arg.itemid ;
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
	public int probability  = 0  ;
	
	public int getProbability(){
		return this.probability;
	}
	
	public void setProbability(int v){
		this.probability=v;
	}
	
	
};