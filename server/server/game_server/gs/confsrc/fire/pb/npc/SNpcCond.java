package fire.pb.npc;


public class SNpcCond implements mytools.ConvMain.Checkable {


	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SNpcCond(){
		super();
	}
	public SNpcCond(SNpcCond arg){
		this.condid=arg.condid ;
		this.args1=arg.args1 ;
		this.args2=arg.args2 ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=condid;
				
				if(tmprefvalue < 1) throw new RuntimeException("SNpcCond.condid="+tmprefvalue+",所以不满足条件 SNpcCond.condid < 1");
			}while(false);
	}
	/**
	 * 
	 */
	public int condid  = 0  ;
	
	public int getCondid(){
		return this.condid;
	}
	
	public void setCondid(int v){
		this.condid=v;
	}
	
	/**
	 * 
	 */
	public int args1  = 0  ;
	
	public int getArgs1(){
		return this.args1;
	}
	
	public void setArgs1(int v){
		this.args1=v;
	}
	
	/**
	 * 
	 */
	public int args2  = 0  ;
	
	public int getArgs2(){
		return this.args2;
	}
	
	public void setArgs2(int v){
		this.args2=v;
	}
	
	
};