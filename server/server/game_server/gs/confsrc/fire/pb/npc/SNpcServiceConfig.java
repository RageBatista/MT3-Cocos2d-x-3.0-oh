package fire.pb.npc;


public class SNpcServiceConfig implements mytools.ConvMain.Checkable ,Comparable<SNpcServiceConfig>{

	public int compareTo(SNpcServiceConfig o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SNpcServiceConfig(){
		super();
	}
	public SNpcServiceConfig(SNpcServiceConfig arg){
		this.id=arg.id ;
		this.services=arg.services ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SNpcServiceConfig.id="+tmprefvalue+",所以不满足条件 SNpcServiceConfig.id < 1");
			}while(false);
	}
	/**
	 * npc id
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
	public java.util.ArrayList<Integer> services  ;
	
	public java.util.ArrayList<Integer> getServices(){
		return this.services;
	}
	
	public void setServices(java.util.ArrayList<Integer> v){
		this.services=v;
	}
	
	
};