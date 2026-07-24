package fire.pb.qiannengguo;


public class SQiannengguoProp implements mytools.ConvMain.Checkable ,Comparable<SQiannengguoProp>{

	public int compareTo(SQiannengguoProp o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SQiannengguoProp(){
		super();
	}
	public SQiannengguoProp(SQiannengguoProp arg){
		this.id=arg.id ;
		this.minvalue=arg.minvalue ;
		this.maxvalue=arg.maxvalue ;
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
	public int minvalue  = 0  ;
	
	public int getMinvalue(){
		return this.minvalue;
	}
	
	public void setMinvalue(int v){
		this.minvalue=v;
	}
	
	/**
	 * 
	 */
	public int maxvalue  = 0  ;
	
	public int getMaxvalue(){
		return this.maxvalue;
	}
	
	public void setMaxvalue(int v){
		this.maxvalue=v;
	}
	
	
};