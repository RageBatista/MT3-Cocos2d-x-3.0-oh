package fire.pb.huanhua;


public class SHuanhuaUseConfig implements mytools.ConvMain.Checkable ,Comparable<SHuanhuaUseConfig>{

	public int compareTo(SHuanhuaUseConfig o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SHuanhuaUseConfig(){
		super();
	}
	public SHuanhuaUseConfig(SHuanhuaUseConfig arg){
		this.id=arg.id ;
		this.skillid=arg.skillid ;
		this.level=arg.level ;
		this.cards=arg.cards ;
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
	public int level  = 0  ;
	
	public int getLevel(){
		return this.level;
	}
	
	public void setLevel(int v){
		this.level=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> cards  ;
	
	public java.util.ArrayList<Integer> getCards(){
		return this.cards;
	}
	
	public void setCards(java.util.ArrayList<Integer> v){
		this.cards=v;
	}
	
	
};