package fire.pb.item;


public class Szuoqicolour implements mytools.ConvMain.Checkable ,Comparable<Szuoqicolour>{

	public int compareTo(Szuoqicolour o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public Szuoqicolour(){
		super();
	}
	public Szuoqicolour(Szuoqicolour arg){
		this.id=arg.id ;
		this.yanse=arg.yanse ;
		this.itemcode=arg.itemcode ;
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
	public String yanse  = null  ;
	
	public String getYanse(){
		return this.yanse;
	}
	
	public void setYanse(String v){
		this.yanse=v;
	}
	
	/**
	 * 
	 */
	public int itemcode  = 0  ;
	
	public int getItemcode(){
		return this.itemcode;
	}
	
	public void setItemcode(int v){
		this.itemcode=v;
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