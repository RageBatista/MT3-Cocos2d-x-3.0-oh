package fire.pb.fushi;


public class SFestivalLivenessReward implements mytools.ConvMain.Checkable ,Comparable<SFestivalLivenessReward>{

	public int compareTo(SFestivalLivenessReward o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SFestivalLivenessReward(){
		super();
	}
	public SFestivalLivenessReward(SFestivalLivenessReward arg){
		this.id=arg.id ;
		this.starttime=arg.starttime ;
		this.endtime=arg.endtime ;
		this.activeness=arg.activeness ;
		this.itemids=arg.itemids ;
		this.itemnums=arg.itemnums ;
		this.isbinds=arg.isbinds ;
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
	public java.util.ArrayList<Integer> activeness  ;
	
	public java.util.ArrayList<Integer> getActiveness(){
		return this.activeness;
	}
	
	public void setActiveness(java.util.ArrayList<Integer> v){
		this.activeness=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> itemids  ;
	
	public java.util.ArrayList<Integer> getItemids(){
		return this.itemids;
	}
	
	public void setItemids(java.util.ArrayList<Integer> v){
		this.itemids=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> itemnums  ;
	
	public java.util.ArrayList<Integer> getItemnums(){
		return this.itemnums;
	}
	
	public void setItemnums(java.util.ArrayList<Integer> v){
		this.itemnums=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> isbinds  ;
	
	public java.util.ArrayList<Integer> getIsbinds(){
		return this.isbinds;
	}
	
	public void setIsbinds(java.util.ArrayList<Integer> v){
		this.isbinds=v;
	}
	
	
};