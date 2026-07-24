package fire.pb.pet;


public class SPetFashion implements mytools.ConvMain.Checkable ,Comparable<SPetFashion>{

	public int compareTo(SPetFashion o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SPetFashion(){
		super();
	}
	public SPetFashion(SPetFashion arg){
		this.id=arg.id ;
		this.defaultid=arg.defaultid ;
		this.fashionid=arg.fashionid ;
		this.fashionshape=arg.fashionshape ;
		this.fashiontitle=arg.fashiontitle ;
		this.fashioncost=arg.fashioncost ;
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
	public int defaultid  = 0  ;
	
	public int getDefaultid(){
		return this.defaultid;
	}
	
	public void setDefaultid(int v){
		this.defaultid=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> fashionid  ;
	
	public java.util.ArrayList<Integer> getFashionid(){
		return this.fashionid;
	}
	
	public void setFashionid(java.util.ArrayList<Integer> v){
		this.fashionid=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> fashionshape  ;
	
	public java.util.ArrayList<Integer> getFashionshape(){
		return this.fashionshape;
	}
	
	public void setFashionshape(java.util.ArrayList<Integer> v){
		this.fashionshape=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> fashiontitle  ;
	
	public java.util.ArrayList<Integer> getFashiontitle(){
		return this.fashiontitle;
	}
	
	public void setFashiontitle(java.util.ArrayList<Integer> v){
		this.fashiontitle=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> fashioncost  ;
	
	public java.util.ArrayList<Integer> getFashioncost(){
		return this.fashioncost;
	}
	
	public void setFashioncost(java.util.ArrayList<Integer> v){
		this.fashioncost=v;
	}
	
	
};