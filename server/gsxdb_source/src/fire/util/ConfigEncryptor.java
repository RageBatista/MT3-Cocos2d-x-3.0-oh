package fire.util;

/**
 * 配置加密工具类
 * 用于加密和解密配置文件中的敏感信息
 *
 * 使用方法：
 * 1. 加密: java fire.util.ConfigEncryptor encrypt "原文"
 * 2. 解密: java fire.util.ConfigEncryptor decrypt "密文"
 * 3. 配置文件中使用: sys.mysql.pass=ENC(加密后的密文)
 *
 * 注意事项：
 * - 加密密钥应从环境变量 CONFIG_ENCRYPTION_KEY 获取
 * - 生产环境密钥应存储在安全的密钥管理服务中（如Vault）
 * - 不要将加密密钥硬编码在代码中
 *
 * @author MT3 Security Team
 * @version 1.0
 * @date 2025-11-26
 */
public class ConfigEncryptor {

    // 简化版实现（生产环境请使用Jasypt）
    private static final String ENCRYPTION_KEY = getEncryptionKey();

    /**
     * 从环境变量获取加密密钥
     * 优先级：
     * 1. 环境变量 CONFIG_ENCRYPTION_KEY
     * 2. JVM系统属性 -DCONFIG_ENCRYPTION_KEY
     * 3. 默认密钥（仅用于开发环境）
     */
    private static String getEncryptionKey() {
        // 从环境变量获取
        String key = System.getenv("CONFIG_ENCRYPTION_KEY");
        if (key != null && !key.isEmpty()) {
            return key;
        }

        // 从JVM系统属性获取
        key = System.getProperty("CONFIG_ENCRYPTION_KEY");
        if (key != null && !key.isEmpty()) {
            return key;
        }

        // 默认密钥（仅用于开发环境，生产环境必须设置环境变量）
        System.err.println("[WARNING] Using default encryption key! " +
                          "Please set CONFIG_ENCRYPTION_KEY in production!");
        return "MT3_GameServer_Default_Key_2025";
    }

    /**
     * 简单的XOR加密（生产环境建议使用AES256）
     * 这里为了示例简化，实际应使用javax.crypto.Cipher
     */
    public static String encrypt(String plainText) {
        if (plainText == null || plainText.isEmpty()) {
            return plainText;
        }

        try {
            byte[] key = ENCRYPTION_KEY.getBytes("UTF-8");
            byte[] input = plainText.getBytes("UTF-8");
            byte[] output = new byte[input.length];

            for (int i = 0; i < input.length; i++) {
                output[i] = (byte) (input[i] ^ key[i % key.length]);
            }

            return base64Encode(output);
        } catch (Exception e) {
            throw new RuntimeException("Encryption failed", e);
        }
    }

    /**
     * 解密
     */
    public static String decrypt(String encryptedText) {
        if (encryptedText == null || encryptedText.isEmpty()) {
            return encryptedText;
        }

        try {
            byte[] key = ENCRYPTION_KEY.getBytes("UTF-8");
            byte[] input = base64Decode(encryptedText);
            byte[] output = new byte[input.length];

            for (int i = 0; i < input.length; i++) {
                output[i] = (byte) (input[i] ^ key[i % key.length]);
            }

            return new String(output, "UTF-8");
        } catch (Exception e) {
            throw new RuntimeException("Decryption failed", e);
        }
    }

    /**
     * Base64编码（Java 8+可用）
     */
    private static String base64Encode(byte[] data) {
        return java.util.Base64.getEncoder().encodeToString(data);
    }

    /**
     * Base64解码
     */
    private static byte[] base64Decode(String data) {
        return java.util.Base64.getDecoder().decode(data);
    }

    /**
     * 处理配置值
     * 如果以ENC(开头，则解密；否则返回原值
     */
    public static String processConfigValue(String value) {
        if (value == null || value.isEmpty()) {
            return value;
        }

        if (value.startsWith("ENC(") && value.endsWith(")")) {
            String encrypted = value.substring(4, value.length() - 1);
            return decrypt(encrypted);
        }

        return value;
    }

    /**
     * 命令行工具
     * 用法：
     *   java fire.util.ConfigEncryptor encrypt "123456"
     *   java fire.util.ConfigEncryptor decrypt "xMpCOKC5..."
     */
    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("Usage:");
            System.out.println("  Encrypt: java fire.util.ConfigEncryptor encrypt <plaintext>");
            System.out.println("  Decrypt: java fire.util.ConfigEncryptor decrypt <encrypted>");
            System.out.println();
            System.out.println("Examples:");
            System.out.println("  java fire.util.ConfigEncryptor encrypt \"123456\"");
            System.out.println("  Output: ENC(xMpCOKC5I4INzFCab2o0Qw==)");
            System.out.println();
            System.out.println("  Use in config file:");
            System.out.println("  sys.mysql.pass=ENC(xMpCOKC5I4INzFCab2o0Qw==)");
            return;
        }

        String operation = args[0];
        String value = args[1];

        try {
            if ("encrypt".equalsIgnoreCase(operation)) {
                String encrypted = encrypt(value);
                System.out.println("Encrypted value:");
                System.out.println("ENC(" + encrypted + ")");
                System.out.println();
                System.out.println("Use in config file:");
                System.out.println("sys.mysql.pass=ENC(" + encrypted + ")");
            } else if ("decrypt".equalsIgnoreCase(operation)) {
                // 如果输入带有ENC()包装，先去掉
                if (value.startsWith("ENC(") && value.endsWith(")")) {
                    value = value.substring(4, value.length() - 1);
                }
                String decrypted = decrypt(value);
                System.out.println("Decrypted value:");
                System.out.println(decrypted);
            } else {
                System.err.println("Unknown operation: " + operation);
                System.err.println("Use 'encrypt' or 'decrypt'");
                System.exit(1);
            }
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
