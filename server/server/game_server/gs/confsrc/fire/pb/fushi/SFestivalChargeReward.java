package fire.pb.fushi;


public class SFestivalChargeReward implements mytools.ConvMain.Checkable ,Comparable<SFestivalChargeReward>{

	public int compareTo(SFestivalChargeReward o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SFestivalChargeReward(){
		super();
	}
	public SFestivalChargeReward(SFestivalChargeReward arg){
		this.id=arg.id ;
		this.starttime=arg.starttime ;
		this.endtime=arg.endtime ;
		this.itemid=arg.itemid ;
		this.itemnum=arg.itemnum ;
		this.isbind=arg.isbind ;
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
	public String starttime  = null  ;
	
	public String getStarttime(){
		return this.starttime;
	}
	
	public void setStarttime(String v){
		this.starttime=v;
	}
	
	/**
	 * 
	 */
	public String endtime  = null  ;
	
	public String getEndtime(){
		return this.endtime;
	}
	
	public void setEndtime(String v){
		this.endtime=v;
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
	public int itemnum  = 0  ;
	
	public int getItemnum(){
		return this.itemnum;
	}
	
	public void setItemnum(int v){
		this.itemnum=v;
	}
	
	/**
	 * 
	 */
	public int isbind  = 0  ;
	
	public int getIsbind(){
		return this.isbind;
	}
	
	public void setIsbind(int v){
		this.isbind=v;
	}
	
	
};