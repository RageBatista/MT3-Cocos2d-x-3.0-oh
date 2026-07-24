package fire.pb.game;


public class SLeaderAward implements mytools.ConvMain.Checkable ,Comparable<SLeaderAward>{

	public int compareTo(SLeaderAward o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SLeaderAward(){
		super();
	}
	public SLeaderAward(SLeaderAward arg){
		this.id=arg.id ;
		this.awardId=arg.awardId ;
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
	public int awardId  = 0  ;
	
	public int getAwardId(){
		return this.awardId;
	}
	
	public void setAwardId(int v){
		this.awardId=v;
	}
	
	
};