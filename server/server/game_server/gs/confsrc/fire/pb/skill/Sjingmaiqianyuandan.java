package fire.pb.skill;


public class Sjingmaiqianyuandan implements mytools.ConvMain.Checkable ,Comparable<Sjingmaiqianyuandan>{

	public int compareTo(Sjingmaiqianyuandan o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public Sjingmaiqianyuandan(){
		super();
	}
	public Sjingmaiqianyuandan(Sjingmaiqianyuandan arg){
		this.id=arg.id ;
		this.huoli=arg.huoli ;
		this.exp=arg.exp ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("Sjingmaiqianyuandan.id="+tmprefvalue+",所以不满足条件 Sjingmaiqianyuandan.id < 1");
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
	public int huoli  = 0  ;
	
	public int getHuoli(){
		return this.huoli;
	}
	
	public void setHuoli(int v){
		this.huoli=v;
	}
	
	/**
	 * 
	 */
	public int exp  = 0  ;
	
	public int getExp(){
		return this.exp;
	}
	
	public void setExp(int v){
		this.exp=v;
	}
	
	
};