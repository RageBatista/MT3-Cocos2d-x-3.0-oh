package fire.pb.item;


public class Ssuijiride implements mytools.ConvMain.Checkable ,Comparable<Ssuijiride>{

	public int compareTo(Ssuijiride o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public Ssuijiride(){
		super();
	}
	public Ssuijiride(Ssuijiride arg){
		this.id=arg.id ;
		this.itemid=arg.itemid ;
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
	public int itemid  = 0  ;
	
	public int getItemid(){
		return this.itemid;
	}
	
	public void setItemid(int v){
		this.itemid=v;
	}
	
	
};