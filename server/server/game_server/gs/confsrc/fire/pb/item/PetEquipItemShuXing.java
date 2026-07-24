package fire.pb.item;


public class PetEquipItemShuXing  extends ItemShuXing {

	public int compareTo(PetEquipItemShuXing o){
		return this.id-o.id;
	}

	
	public PetEquipItemShuXing(ItemShuXing arg){
		super(arg);
	}
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public PetEquipItemShuXing(){
		super();
	}
	public PetEquipItemShuXing(PetEquipItemShuXing arg){
		super(arg);
		this.pos=arg.pos ;
		this.pro=arg.pro ;
		this.min=arg.min ;
		this.max=arg.max ;
		this.skill=arg.skill ;
		this.itemid=arg.itemid ;
		this.itemnum=arg.itemnum ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			super.checkValid(objs);
	}
	/**
	 * 
	 */
	public int pos  = 0  ;
	
	public int getPos(){
		return this.pos;
	}
	
	public void setPos(int v){
		this.pos=v;
	}
	
	/**
	 * 
	 */
	public String pro  = null  ;
	
	public String getPro(){
		return this.pro;
	}
	
	public void setPro(String v){
		this.pro=v;
	}
	
	/**
	 * 
	 */
	public String min  = null  ;
	
	public String getMin(){
		return this.min;
	}
	
	public void setMin(String v){
		this.min=v;
	}
	
	/**
	 * 
	 */
	public String max  = null  ;
	
	public String getMax(){
		return this.max;
	}
	
	public void setMax(String v){
		this.max=v;
	}
	
	/**
	 * 
	 */
	public String skill  = null  ;
	
	public String getSkill(){
		return this.skill;
	}
	
	public void setSkill(String v){
		this.skill=v;
	}
	
	/**
	 * 
	 */
	public int itemid  = 0  ;
	
	public int getItemid(){
		return this.itemid;
	}
	
	public void setItemid(int v){
		this.itemid=v;
	}
	
	/**
	 * 
	 */
	public int itemnum  = 0  ;
	
	public int getItemnum(){
		return this.itemnum;
	}
	
	public void setItemnum(int v){
		this.itemnum=v;
	}
	
	
};