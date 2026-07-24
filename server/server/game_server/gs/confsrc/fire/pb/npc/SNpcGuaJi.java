package fire.pb.npc;


public class SNpcGuaJi implements mytools.ConvMain.Checkable ,Comparable<SNpcGuaJi>{

	public int compareTo(SNpcGuaJi o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SNpcGuaJi(){
		super();
	}
	public SNpcGuaJi(SNpcGuaJi arg){
		this.id=arg.id ;
		this.mapid=arg.mapid ;
		this.npcs=arg.npcs ;
		this.actid=arg.actid ;
		this.awardCnt=arg.awardCnt ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SNpcGuaJi.id="+tmprefvalue+",所以不满足条件 SNpcGuaJi.id < 1");
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
	public String mapid  = null  ;
	
	public String getMapid(){
		return this.mapid;
	}
	
	public void setMapid(String v){
		this.mapid=v;
	}
	
	/**
	 * 
	 */
	public String npcs  = null  ;
	
	public String getNpcs(){
		return this.npcs;
	}
	
	public void setNpcs(String v){
		this.npcs=v;
	}
	
	/**
	 * 
	 */
	public int actid  = 0  ;
	
	public int getActid(){
		return this.actid;
	}
	
	public void setActid(int v){
		this.actid=v;
	}
	
	/**
	 * 
	 */
	public int awardCnt  = 0  ;
	
	public int getAwardCnt(){
		return this.awardCnt;
	}
	
	public void setAwardCnt(int v){
		this.awardCnt=v;
	}
	
	
};