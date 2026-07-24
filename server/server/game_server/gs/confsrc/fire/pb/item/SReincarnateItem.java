package fire.pb.item;


public class SReincarnateItem implements mytools.ConvMain.Checkable ,Comparable<SReincarnateItem>{

	public int compareTo(SReincarnateItem o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SReincarnateItem(){
		super();
	}
	public SReincarnateItem(SReincarnateItem arg){
		this.id=arg.id ;
		this.tolevel=arg.tolevel ;
		this.cons=arg.cons ;
		this.iq=arg.iq ;
		this.str=arg.str ;
		this.endu=arg.endu ;
		this.agi=arg.agi ;
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
	public int tolevel  = 0  ;
	
	public int getTolevel(){
		return this.tolevel;
	}
	
	public void setTolevel(int v){
		this.tolevel=v;
	}
	
	/**
	 * 
	 */
	public int cons  = 0  ;
	
	public int getCons(){
		return this.cons;
	}
	
	public void setCons(int v){
		this.cons=v;
	}
	
	/**
	 * 
	 */
	public int iq  = 0  ;
	
	public int getIq(){
		return this.iq;
	}
	
	public void setIq(int v){
		this.iq=v;
	}
	
	/**
	 * 
	 */
	public int str  = 0  ;
	
	public int getStr(){
		return this.str;
	}
	
	public void setStr(int v){
		this.str=v;
	}
	
	/**
	 * 
	 */
	public int endu  = 0  ;
	
	public int getEndu(){
		return this.endu;
	}
	
	public void setEndu(int v){
		this.endu=v;
	}
	
	/**
	 * 
	 */
	public int agi  = 0  ;
	
	public int getAgi(){
		return this.agi;
	}
	
	public void setAgi(int v){
		this.agi=v;
	}
	
	
};