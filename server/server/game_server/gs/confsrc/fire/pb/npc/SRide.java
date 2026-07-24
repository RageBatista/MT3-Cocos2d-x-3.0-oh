package fire.pb.npc;


public class SRide implements mytools.ConvMain.Checkable ,Comparable<SRide>{

	public int compareTo(SRide o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SRide(){
		super();
	}
	public SRide(SRide arg){
		this.id=arg.id ;
		this.ridemodel=arg.ridemodel ;
		this.ridebuff=arg.ridebuff ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SRide.id="+tmprefvalue+",所以不满足条件 SRide.id < 1");
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
	public int ridemodel  = 0  ;
	
	public int getRidemodel(){
		return this.ridemodel;
	}
	
	public void setRidemodel(int v){
		this.ridemodel=v;
	}
	
	/**
	 * 
	 */
	public int ridebuff  = 0  ;
	
	public int getRidebuff(){
		return this.ridebuff;
	}
	
	public void setRidebuff(int v){
		this.ridebuff=v;
	}
	
	
};