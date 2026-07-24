package fire.pb.skill;


public class SInbornConsume implements mytools.ConvMain.Checkable ,Comparable<SInbornConsume>{

	public int compareTo(SInbornConsume o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SInbornConsume(){
		super();
	}
	public SInbornConsume(SInbornConsume arg){
		this.id=arg.id ;
		this.consumes=arg.consumes ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SInbornConsume.id="+tmprefvalue+",所以不满足条件 SInbornConsume.id < 1");
			}while(false);
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
	public java.util.ArrayList<InbornConsume> consumes  ;
	
	public java.util.ArrayList<InbornConsume> getConsumes(){
		return this.consumes;
	}
	
	public void setConsumes(java.util.ArrayList<InbornConsume> v){
		this.consumes=v;
	}
	
	
};