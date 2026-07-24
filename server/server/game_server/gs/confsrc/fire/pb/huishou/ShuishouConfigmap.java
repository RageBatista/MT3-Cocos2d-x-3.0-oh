package fire.pb.huishou;


public class ShuishouConfigmap implements mytools.ConvMain.Checkable ,Comparable<ShuishouConfigmap>{

	public int compareTo(ShuishouConfigmap o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public ShuishouConfigmap(){
		super();
	}
	public ShuishouConfigmap(ShuishouConfigmap arg){
		this.id=arg.id ;
		this.type=arg.type ;
		this.itmeid=arg.itmeid ;
		this.itemname=arg.itemname ;
		this.moneytype=arg.moneytype ;
		this.moneynum=arg.moneynum ;
		this.max=arg.max ;
		this.enable=arg.enable ;
		this.startTime=arg.startTime ;
		this.endTime=arg.endTime ;
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
	 * id
	 */
	public int type  = 0  ;
	
	public int getType(){
		return this.type;
	}
	
	public void setType(int v){
		this.type=v;
	}
	
	/**
	 * 道具id
	 */
	public int itmeid  = 0  ;
	
	public int getItmeid(){
		return this.itmeid;
	}
	
	public void setItmeid(int v){
		this.itmeid=v;
	}
	
	/**
	 * 道具名字
	 */
	public String itemname  = null  ;
	
	public String getItemname(){
		return this.itemname;
	}
	
	public void setItemname(String v){
		this.itemname=v;
	}
	
	/**
	 * 货币类型
	 */
	public int moneytype  = 0  ;
	
	public int getMoneytype(){
		return this.moneytype;
	}
	
	public void setMoneytype(int v){
		this.moneytype=v;
	}
	
	/**
	 * 价格
	 */
	public int moneynum  = 0  ;
	
	public int getMoneynum(){
		return this.moneynum;
	}
	
	public void setMoneynum(int v){
		this.moneynum=v;
	}
	
	/**
	 * 道具id
	 */
	public int max  = 0  ;
	
	public int getMax(){
		return this.max;
	}
	
	public void setMax(int v){
		this.max=v;
	}
	
	/**
	 * 是否限时
	 */
	public int enable  = 0  ;
	
	public int getEnable(){
		return this.enable;
	}
	
	public void setEnable(int v){
		this.enable=v;
	}
	
	/**
	 * 开始时间
	 */
	public String startTime  = null  ;
	
	public String getStartTime(){
		return this.startTime;
	}
	
	public void setStartTime(String v){
		this.startTime=v;
	}
	
	/**
	 * 结束时间
	 */
	public String endTime  = null  ;
	
	public String getEndTime(){
		return this.endTime;
	}
	
	public void setEndTime(String v){
		this.endTime=v;
	}
	
	
};