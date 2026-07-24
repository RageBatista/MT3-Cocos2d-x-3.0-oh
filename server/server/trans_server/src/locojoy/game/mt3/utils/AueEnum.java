package locojoy.game.mt3.utils;

/**
 * 音频编码
 */
public enum AueEnum {

	WAV("wav"), PCM("pcm"), SPEEX("speexwb");
	
	private String aue;
	
	private AueEnum(String aue) {
		this.aue = aue;
	}
	
	public String value() {
		return this.aue;
	}
	
}
