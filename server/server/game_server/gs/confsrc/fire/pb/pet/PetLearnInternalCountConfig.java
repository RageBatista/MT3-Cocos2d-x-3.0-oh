package fire.pb.pet;


public class PetLearnInternalCountConfig implements mytools.ConvMain.Checkable ,Comparable<PetLearnInternalCountConfig>{

	public int compareTo(PetLearnInternalCountConfig o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public PetLearnInternalCountConfig(){
		super();
	}
	public PetLearnInternalCountConfig(PetLearnInternalCountConfig arg){
		this.id=arg.id ;
		this.rate=arg.rate ;
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
	public double rate  = 0.0  ;
	
	public double getRate(){
		return this.rate;
	}
	
	public void setRate(double v){
		this.rate=v;
	}
	
	
};