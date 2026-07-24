package fire.pb.item;


public class Spettaozhuang implements mytools.ConvMain.Checkable ,Comparable<Spettaozhuang>{

	public int compareTo(Spettaozhuang o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public Spettaozhuang(){
		super();
	}
	public Spettaozhuang(Spettaozhuang arg){
		this.id=arg.id ;
		this.name=arg.name ;
		this.skill=arg.skill ;
		this.petid=arg.petid ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
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
	public String name  = null  ;
	
	public String getName(){
		return this.name;
	}
	
	public void setName(String v){
		this.name=v;
	}
	
	/**
	 * 
	 */
	public int skill  = 0  ;
	
	public int getSkill(){
		return this.skill;
	}
	
	public void setSkill(int v){
		this.skill=v;
	}
	
	/**
	 * 
	 */
	public int petid  = 0  ;
	
	public int getPetid(){
		return this.petid;
	}
	
	public void setPetid(int v){
		this.petid=v;
	}
	
	
};