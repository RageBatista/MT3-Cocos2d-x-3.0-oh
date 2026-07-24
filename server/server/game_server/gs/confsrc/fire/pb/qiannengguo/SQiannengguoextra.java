package fire.pb.qiannengguo;


public class SQiannengguoextra implements mytools.ConvMain.Checkable ,Comparable<SQiannengguoextra>{

	public int compareTo(SQiannengguoextra o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SQiannengguoextra(){
		super();
	}
	public SQiannengguoextra(SQiannengguoextra arg){
		this.id=arg.id ;
		this.needcount=arg.needcount ;
		this.proppool=arg.proppool ;
		this.mincountvalue=arg.mincountvalue ;
		this.maxcountvalue=arg.maxcountvalue ;
		this.doublerate=arg.doublerate ;
		this.costmoney=arg.costmoney ;
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
	public int needcount  = 0  ;
	
	public int getNeedcount(){
		return this.needcount;
	}
	
	public void setNeedcount(int v){
		this.needcount=v;
	}
	
	/**
	 * 
	 */
	public String proppool  = null  ;
	
	public String getProppool(){
		return this.proppool;
	}
	
	public void setProppool(String v){
		this.proppool=v;
	}
	
	/**
	 * 
	 */
	public int mincountvalue  = 0  ;
	
	public int getMincountvalue(){
		return this.mincountvalue;
	}
	
	public void setMincountvalue(int v){
		this.mincountvalue=v;
	}
	
	/**
	 * 
	 */
	public int maxcountvalue  = 0  ;
	
	public int getMaxcountvalue(){
		return this.maxcountvalue;
	}
	
	public void setMaxcountvalue(int v){
		this.maxcountvalue=v;
	}
	
	/**
	 * 
	 */
	public double doublerate  = 0.0  ;
	
	public double getDoublerate(){
		return this.doublerate;
	}
	
	public void setDoublerate(double v){
		this.doublerate=v;
	}
	
	/**
	 * 
	 */
	public int costmoney  = 0  ;
	
	public int getCostmoney(){
		return this.costmoney;
	}
	
	public void setCostmoney(int v){
		this.costmoney=v;
	}
	
	
};