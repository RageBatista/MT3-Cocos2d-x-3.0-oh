package fire.pb.game;


public class STotalReaward implements mytools.ConvMain.Checkable ,Comparable<STotalReaward>{

	public int compareTo(STotalReaward o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public STotalReaward(){
		super();
	}
	public STotalReaward(STotalReaward arg){
		this.id=arg.id ;
		this.item1id=arg.item1id ;
		this.item1num=arg.item1num ;
		this.item2id=arg.item2id ;
		this.item2num=arg.item2num ;
		this.item3id=arg.item3id ;
		this.item3num=arg.item3num ;
		this.needcapacity=arg.needcapacity ;
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
	public int item1id  = 0  ;
	
	public int getItem1id(){
		return this.item1id;
	}
	
	public void setItem1id(int v){
		this.item1id=v;
	}
	
	/**
	 * 
	 */
	public int item1num  = 0  ;
	
	public int getItem1num(){
		return this.item1num;
	}
	
	public void setItem1num(int v){
		this.item1num=v;
	}
	
	/**
	 * 
	 */
	public int item2id  = 0  ;
	
	public int getItem2id(){
		return this.item2id;
	}
	
	public void setItem2id(int v){
		this.item2id=v;
	}
	
	/**
	 * 
	 */
	public int item2num  = 0  ;
	
	public int getItem2num(){
		return this.item2num;
	}
	
	public void setItem2num(int v){
		this.item2num=v;
	}
	
	/**
	 * 
	 */
	public int item3id  = 0  ;
	
	public int getItem3id(){
		return this.item3id;
	}
	
	public void setItem3id(int v){
		this.item3id=v;
	}
	
	/**
	 * 
	 */
	public int item3num  = 0  ;
	
	public int getItem3num(){
		return this.item3num;
	}
	
	public void setItem3num(int v){
		this.item3num=v;
	}
	
	/**
	 * 
	 */
	public int needcapacity  = 0  ;
	
	public int getNeedcapacity(){
		return this.needcapacity;
	}
	
	public void setNeedcapacity(int v){
		this.needcapacity=v;
	}
	
	
};