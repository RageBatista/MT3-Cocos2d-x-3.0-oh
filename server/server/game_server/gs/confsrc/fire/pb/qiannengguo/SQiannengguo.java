package fire.pb.qiannengguo;


public class SQiannengguo implements mytools.ConvMain.Checkable ,Comparable<SQiannengguo>{

	public int compareTo(SQiannengguo o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SQiannengguo(){
		super();
	}
	public SQiannengguo(SQiannengguo arg){
		this.id=arg.id ;
		this.proptype=arg.proptype ;
		this.propvalue=arg.propvalue ;
		this.image=arg.image ;
		this.rate=arg.rate ;
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
	public int proptype  = 0  ;
	
	public int getProptype(){
		return this.proptype;
	}
	
	public void setProptype(int v){
		this.proptype=v;
	}
	
	/**
	 * 
	 */
	public int propvalue  = 0  ;
	
	public int getPropvalue(){
		return this.propvalue;
	}
	
	public void setPropvalue(int v){
		this.propvalue=v;
	}
	
	/**
	 * 
	 */
	public String image  = null  ;
	
	public String getImage(){
		return this.image;
	}
	
	public void setImage(String v){
		this.image=v;
	}
	
	/**
	 * 
	 */
	public int rate  = 0  ;
	
	public int getRate(){
		return this.rate;
	}
	
	public void setRate(int v){
		this.rate=v;
	}
	
	
};