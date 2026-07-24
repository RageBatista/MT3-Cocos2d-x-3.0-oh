package fire.pb.skill;


public class Sjingmaijihuoitem implements mytools.ConvMain.Checkable ,Comparable<Sjingmaijihuoitem>{

	public int compareTo(Sjingmaijihuoitem o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public Sjingmaijihuoitem(){
		super();
	}
	public Sjingmaijihuoitem(Sjingmaijihuoitem arg){
		this.id=arg.id ;
		this.item1=arg.item1 ;
		this.item1num=arg.item1num ;
		this.item2=arg.item2 ;
		this.item2num=arg.item2num ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("Sjingmaijihuoitem.id="+tmprefvalue+",所以不满足条件 Sjingmaijihuoitem.id < 1");
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
	public int item1  = 0  ;
	
	public int getItem1(){
		return this.item1;
	}
	
	public void setItem1(int v){
		this.item1=v;
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
	public int item2  = 0  ;
	
	public int getItem2(){
		return this.item2;
	}
	
	public void setItem2(int v){
		this.item2=v;
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
	
	
};