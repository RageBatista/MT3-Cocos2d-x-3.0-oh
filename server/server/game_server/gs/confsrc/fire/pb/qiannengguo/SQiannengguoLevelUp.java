package fire.pb.qiannengguo;


public class SQiannengguoLevelUp implements mytools.ConvMain.Checkable ,Comparable<SQiannengguoLevelUp>{

	public int compareTo(SQiannengguoLevelUp o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SQiannengguoLevelUp(){
		super();
	}
	public SQiannengguoLevelUp(SQiannengguoLevelUp arg){
		this.id=arg.id ;
		this.levelupvalue=arg.levelupvalue ;
		this.returnvalue=arg.returnvalue ;
		this.openlevel=arg.openlevel ;
		this.resetmoney=arg.resetmoney ;
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
	public int levelupvalue  = 0  ;
	
	public int getLevelupvalue(){
		return this.levelupvalue;
	}
	
	public void setLevelupvalue(int v){
		this.levelupvalue=v;
	}
	
	/**
	 * 
	 */
	public int returnvalue  = 0  ;
	
	public int getReturnvalue(){
		return this.returnvalue;
	}
	
	public void setReturnvalue(int v){
		this.returnvalue=v;
	}
	
	/**
	 * 
	 */
	public int openlevel  = 0  ;
	
	public int getOpenlevel(){
		return this.openlevel;
	}
	
	public void setOpenlevel(int v){
		this.openlevel=v;
	}
	
	/**
	 * 
	 */
	public int resetmoney  = 0  ;
	
	public int getResetmoney(){
		return this.resetmoney;
	}
	
	public void setResetmoney(int v){
		this.resetmoney=v;
	}
	
	
};