package fire.pb.npc;


public class SRideItem implements mytools.ConvMain.Checkable ,Comparable<SRideItem>{

	public int compareTo(SRideItem o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SRideItem(){
		super();
	}
	public SRideItem(SRideItem arg){
		this.id=arg.id ;
		this.rideid=arg.rideid ;
		this.huobi=arg.huobi ;
		this.money=arg.money ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SRideItem.id="+tmprefvalue+",所以不满足条件 SRideItem.id < 1");
			}while(false);
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
	public int rideid  = 0  ;
	
	public int getRideid(){
		return this.rideid;
	}
	
	public void setRideid(int v){
		this.rideid=v;
	}
	
	/**
	 * 
	 */
	public int huobi  = 0  ;
	
	public int getHuobi(){
		return this.huobi;
	}
	
	public void setHuobi(int v){
		this.huobi=v;
	}
	
	/**
	 * 
	 */
	public int money  = 0  ;
	
	public int getMoney(){
		return this.money;
	}
	
	public void setMoney(int v){
		this.money=v;
	}
	
	
};