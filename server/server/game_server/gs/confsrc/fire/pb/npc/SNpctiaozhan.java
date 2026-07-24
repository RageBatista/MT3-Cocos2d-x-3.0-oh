package fire.pb.npc;


public class SNpctiaozhan implements mytools.ConvMain.Checkable ,Comparable<SNpctiaozhan>{

	public int compareTo(SNpctiaozhan o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SNpctiaozhan(){
		super();
	}
	public SNpctiaozhan(SNpctiaozhan arg){
		this.id=arg.id ;
		this.npcid1=arg.npcid1 ;
		this.zdid1=arg.zdid1 ;
		this.npcid2=arg.npcid2 ;
		this.zdid2=arg.zdid2 ;
		this.npcid3=arg.npcid3 ;
		this.zdid3=arg.zdid3 ;
		this.npcid4=arg.npcid4 ;
		this.zdid4=arg.zdid4 ;
		this.npcid5=arg.npcid5 ;
		this.zdid5=arg.zdid5 ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SNpctiaozhan.id="+tmprefvalue+",所以不满足条件 SNpctiaozhan.id < 1");
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
	public int npcid1  = 0  ;
	
	public int getNpcid1(){
		return this.npcid1;
	}
	
	public void setNpcid1(int v){
		this.npcid1=v;
	}
	
	/**
	 * 
	 */
	public int zdid1  = 0  ;
	
	public int getZdid1(){
		return this.zdid1;
	}
	
	public void setZdid1(int v){
		this.zdid1=v;
	}
	
	/**
	 * 
	 */
	public int npcid2  = 0  ;
	
	public int getNpcid2(){
		return this.npcid2;
	}
	
	public void setNpcid2(int v){
		this.npcid2=v;
	}
	
	/**
	 * 
	 */
	public int zdid2  = 0  ;
	
	public int getZdid2(){
		return this.zdid2;
	}
	
	public void setZdid2(int v){
		this.zdid2=v;
	}
	
	/**
	 * 
	 */
	public int npcid3  = 0  ;
	
	public int getNpcid3(){
		return this.npcid3;
	}
	
	public void setNpcid3(int v){
		this.npcid3=v;
	}
	
	/**
	 * 
	 */
	public int zdid3  = 0  ;
	
	public int getZdid3(){
		return this.zdid3;
	}
	
	public void setZdid3(int v){
		this.zdid3=v;
	}
	
	/**
	 * 
	 */
	public int npcid4  = 0  ;
	
	public int getNpcid4(){
		return this.npcid4;
	}
	
	public void setNpcid4(int v){
		this.npcid4=v;
	}
	
	/**
	 * 
	 */
	public int zdid4  = 0  ;
	
	public int getZdid4(){
		return this.zdid4;
	}
	
	public void setZdid4(int v){
		this.zdid4=v;
	}
	
	/**
	 * 
	 */
	public int npcid5  = 0  ;
	
	public int getNpcid5(){
		return this.npcid5;
	}
	
	public void setNpcid5(int v){
		this.npcid5=v;
	}
	
	/**
	 * 
	 */
	public int zdid5  = 0  ;
	
	public int getZdid5(){
		return this.zdid5;
	}
	
	public void setZdid5(int v){
		this.zdid5=v;
	}
	
	
};