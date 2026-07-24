package fire.pb.skill;


public class SPetSkilllw implements mytools.ConvMain.Checkable ,Comparable<SPetSkilllw>{

	public int compareTo(SPetSkilllw o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SPetSkilllw(){
		super();
	}
	public SPetSkilllw(SPetSkilllw arg){
		this.id=arg.id ;
		this.skillid=arg.skillid ;
		this.skillname=arg.skillname ;
		this.addneeditem=arg.addneeditem ;
		this.addneeditemnum=arg.addneeditemnum ;
		this.addneedmoney=arg.addneedmoney ;
		this.removeneeditem=arg.removeneeditem ;
		this.removeneeditemnum=arg.removeneeditemnum ;
		this.removeneedmoney=arg.removeneedmoney ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SPetSkilllw.id="+tmprefvalue+",所以不满足条件 SPetSkilllw.id < 1");
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
	public int skillid  = 0  ;
	
	public int getSkillid(){
		return this.skillid;
	}
	
	public void setSkillid(int v){
		this.skillid=v;
	}
	
	/**
	 * 
	 */
	public String skillname  = null  ;
	
	public String getSkillname(){
		return this.skillname;
	}
	
	public void setSkillname(String v){
		this.skillname=v;
	}
	
	/**
	 * 
	 */
	public int addneeditem  = 0  ;
	
	public int getAddneeditem(){
		return this.addneeditem;
	}
	
	public void setAddneeditem(int v){
		this.addneeditem=v;
	}
	
	/**
	 * 
	 */
	public int addneeditemnum  = 0  ;
	
	public int getAddneeditemnum(){
		return this.addneeditemnum;
	}
	
	public void setAddneeditemnum(int v){
		this.addneeditemnum=v;
	}
	
	/**
	 * 
	 */
	public int addneedmoney  = 0  ;
	
	public int getAddneedmoney(){
		return this.addneedmoney;
	}
	
	public void setAddneedmoney(int v){
		this.addneedmoney=v;
	}
	
	/**
	 * 
	 */
	public int removeneeditem  = 0  ;
	
	public int getRemoveneeditem(){
		return this.removeneeditem;
	}
	
	public void setRemoveneeditem(int v){
		this.removeneeditem=v;
	}
	
	/**
	 * 
	 */
	public int removeneeditemnum  = 0  ;
	
	public int getRemoveneeditemnum(){
		return this.removeneeditemnum;
	}
	
	public void setRemoveneeditemnum(int v){
		this.removeneeditemnum=v;
	}
	
	/**
	 * 
	 */
	public int removeneedmoney  = 0  ;
	
	public int getRemoveneedmoney(){
		return this.removeneedmoney;
	}
	
	public void setRemoveneedmoney(int v){
		this.removeneedmoney=v;
	}
	
	
};