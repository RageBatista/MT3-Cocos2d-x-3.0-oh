package fire.pb.cross;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

/**
 * 安全哈希工具类（已升级）
 *
 * 安全改进：
 * 1. 新增SHA-256/SHA-512哈希方法（替代不安全的MD5）
 * 2. MD5方法已废弃，仅保留向后兼容
 * 3. 支持加盐哈希（防止彩虹表攻击）
 * 4. 提供随机盐生成器
 *
 * 推荐使用：
 * - SHA-256：适用于一般哈希需求
 * - SHA-512：适用于高安全性场景
 * - SHA-256 with salt：适用于密码存储
 *
 * @version 2.0 (安全加固)
 */
public class Md5Util {

	/**
	 * SHA-256哈希（推荐使用）
	 *
	 * @param info 要哈希的信息
	 * @return 十六进制哈希字符串
	 */
	public static String encryptToSHA256(String info) {
		return hash(info, "SHA-256");
	}

	/**
	 * SHA-512哈希（更高安全性）
	 *
	 * @param info 要哈希的信息
	 * @return 十六进制哈希字符串
	 */
	public static String encryptToSHA512(String info) {
		return hash(info, "SHA-512");
	}

	/**
	 * SHA-256加盐哈希（推荐用于密码存储）
	 *
	 * @param info 要哈希的信息
	 * @param salt 盐值
	 * @return 十六进制哈希字符串
	 */
	public static String encryptToSHA256WithSalt(String info, String salt) {
		return hash(info + salt, "SHA-256");
	}

	/**
	 * 生成随机盐值（16字节）
	 *
	 * @return Base64编码的盐值
	 */
	public static String generateSalt() {
		SecureRandom random = new SecureRandom();
		byte[] salt = new byte[16];
		random.nextBytes(salt);
		return java.util.Base64.getEncoder().encodeToString(salt);
	}

	/**
	 * 通用哈希方法
	 *
	 * @param info 要哈希的信息
	 * @param algorithm 哈希算法（SHA-256, SHA-512）
	 * @return 十六进制哈希字符串
	 */
	private static String hash(String info, String algorithm) {
		try {
			MessageDigest alga = MessageDigest.getInstance(algorithm);
			alga.update(info.getBytes("UTF-8"));
			byte[] digesta = alga.digest();
			return byte2hex(digesta);
		} catch (Exception e) {
			throw new RuntimeException(algorithm + "哈希失败", e);
		}
	}

	/**
	 * MD5哈希（已废弃，不推荐使用）
	 *
	 * 安全警告：MD5已不再安全，易受碰撞攻击。
	 * 请使用encryptToSHA256或encryptToSHA512替代。
	 *
	 * 此方法仅保留用于向后兼容旧系统。
	 *
	 * @param info 要加密的信息
	 * @return 加密后的字符串
	 * @deprecated 使用encryptToSHA256替代
	 */
	@Deprecated
	public static String encryptToMD5(String info) {
		byte[] digesta = null;
		try {
			// 得到一个md5的消息摘要
			MessageDigest alga = MessageDigest.getInstance("MD5");
			// 添加要进行计算摘要的信息
			alga.update(info.getBytes("UTF-8"));
			// 得到该摘要
			digesta = alga.digest();
		} catch (NoSuchAlgorithmException e) {
			throw new RuntimeException("MD5哈希失败", e);
		} catch (java.io.UnsupportedEncodingException e) {
			throw new RuntimeException("编码错误", e);
		}
		// 将摘要转为字符串
		String rs = byte2hex(digesta);
		return rs;
	}

	/**
	 * MD5哈希变体2（已废弃）
	 *
	 * @param info 要加密的信息
	 * @return 加密后的字符串（错误实现，不应使用）
	 * @deprecated 此方法实现错误，请勿使用
	 */
	@Deprecated
	@SuppressWarnings("null")
	public static String encryptToMD52(String info) {
		byte[] digesta = null;
		try {
			MessageDigest alga = MessageDigest.getInstance("MD5");
			alga.update(info.getBytes("UTF-8"));
			digesta = alga.digest();
		} catch (NoSuchAlgorithmException e) {
			throw new RuntimeException("MD5哈希失败", e);
		} catch (java.io.UnsupportedEncodingException e) {
			throw new RuntimeException("编码错误", e);
		}
		// 注意：这个实现是错误的，digesta.toString()不会返回哈希值
		String rs = (digesta == null) ? "" : digesta.toString();
		return rs;
	}

	/**
	 * 将二进制转化为16进制字符串
	 *
	 * @param b 二进制字节数组
	 * @return 十六进制字符串
	 */
	public static String byte2hex(byte[] b) {
		String hs = "";
		String stmp = "";
		for (int n = 0; n < b.length; n++) {
			stmp = (java.lang.Integer.toHexString(b[n] & 0XFF));
			if (stmp.length() == 1) {
				hs = hs + "0" + stmp;
			} else {
				hs = hs + stmp;
			}
		}
		return hs.toUpperCase();
	}

	/**
	 * 测试方法
	 *
	 * @param args 命令行参数
	 */
	public static void main(String[] args) {
		String timestamp = "" + System.currentTimeMillis();
		System.out.println("原文: " + timestamp);
		System.out.println("MD5 (已废弃): " + encryptToMD5(timestamp));
		System.out.println("SHA-256: " + encryptToSHA256(timestamp));
		System.out.println("SHA-512: " + encryptToSHA512(timestamp));

		String salt = generateSalt();
		System.out.println("随机盐: " + salt);
		System.out.println("SHA-256加盐: " + encryptToSHA256WithSalt(timestamp, salt));
	}
}
