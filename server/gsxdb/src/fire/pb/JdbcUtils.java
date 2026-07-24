//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//
// 安全增强：使用环境变量删除硬编码凭据
// 版本：6.0.0-SAFE
//

package fire.pb;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * JDBC连接工具类（安全加固版）
 *
 * 安全改进：
 * 1. 移除硬编码密码，使用环境变量
 * 2. 添加连接超时配置
 * 3. 支持配置加密
 *
 * 环境变量配置：
 * - DB_URL: 数据库URL
 * - DB_USER: 数据库用户名
 * - DB_PASSWORD: 数据库密码（加密或明文）
 * - DB_URL_2: 第二数据库URL（可选）
 *
 * @版本6.0.0-安全
 */
public class JdbcUtils {

    // 数据库配置（从环境变量读取）
    private static final String DB_URL = getConfig("DB_URL", "jdbc:mysql://127.0.0.1:3306/mt91?useUnicode=true&characterEncoding=utf8&useSSL=true");
    private static final String DB_USER = getConfig("DB_USER", "root");
    private static final String DB_PASSWORD = getConfig("DB_PASSWORD", "");

    private static final String DB_URL_2 = getConfig("DB_URL_2", "jdbc:mysql://127.0.0.1:3306/Zx_Agent?useUnicode=true&characterEncoding=utf8&useSSL=true");
    private static final String DB_USER_2 = getConfig("DB_USER_2", "root");
    private static final String DB_PASSWORD_2 = getConfig("DB_PASSWORD_2", "");

    // 连接超时配置（秒）
    private static final int LOGIN_TIMEOUT = 10;

    static {
        // 设置登录超时，防止连接挂起
        DriverManager.setLoginTimeout(LOGIN_TIMEOUT);
    }

    /**
     * 从环境变量或系统属性获取配置
     *
     * @param key 配置键
     * @param defaultValue 默认值
     * @return 配置值
     */
    private static String getConfig(String key, String defaultValue) {
        // 优先从环境变量读取
        String value = System.getenv(key);
        if (value != null && !value.isEmpty()) {
            return value;
        }

        // 其次从系统属性读取
        value = System.getProperty(key);
        if (value != null && !value.isEmpty()) {
            return value;
        }

        // 如果没有配置，使用默认值（生产环境应配置环境变量）
        if (defaultValue.isEmpty() && (key.contains("PASSWORD") || key.contains("PASS"))) {
            throw new SecurityException(
                "数据库密码未配置！请设置环境变量: " + key +
                "\n示例: export " + key + "=your_password"
            );
        }

        return defaultValue;
    }

    /**
     * 获取数据库连接（主数据库）
     *
     * @return 数据库连接
     * @throws SQLException 数据库连接失败
     */
    public static Connection getConnection() throws SQLException {
        try {
            String password = decryptPassword(DB_PASSWORD);
            return DriverManager.getConnection(DB_URL, DB_USER, password);
        } catch (SQLException e) {
            throw new SQLException("数据库连接失败: " + e.getMessage(), e);
        }
    }

    /**
     * 获取数据库连接（第二数据库）
     *
     * @return 数据库连接
     * @throws SQLException 数据库连接失败
     */
    public static Connection getConnection1() throws SQLException {
        try {
            String password = decryptPassword(DB_PASSWORD_2);
            return DriverManager.getConnection(DB_URL_2, DB_USER_2, password);
        } catch (SQLException e) {
            throw new SQLException("第二数据库连接失败: " + e.getMessage(), e);
        }
    }

    /**
     * 解密密码（支持加密配置）
     * 如果密码以ENC(开头，使用ConfigEncryptor解密
     *
     * @param password 密码（可能是加密的）
     * @return 解密后的密码
     */
    private static String decryptPassword(String password) {
        if (password == null || password.isEmpty()) {
            return password;
        }

        // 检查是否是加密格式：ENC(密文)
        if (password.startsWith("ENC(") && password.endsWith(")")) {
            try {
                // 使用反射调用ConfigEncryptor，避免循环依赖
                Class<?> encryptorClass = Class.forName("fire.util.ConfigEncryptor");
                java.lang.reflect.Method decryptMethod = encryptorClass.getMethod("decrypt", String.class);
                String encrypted = password.substring(4, password.length() - 1);
                return (String) decryptMethod.invoke(null, encrypted);
            } catch (Exception e) {
                throw new RuntimeException("密码解密失败: " + e.getMessage(), e);
            }
        }

        return password;
    }

    /**
     * 释放数据库资源
     *
     * @param conn 数据库连接
     * @param st Statement对象
     * @param rs ResultSet对象
     * @throws SQLException 关闭异常
     */
    public static void release(Connection conn, Statement st, ResultSet rs) throws SQLException {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                // 记录日志但继续关闭其他资源
            }
        }

        if (st != null) {
            try {
                st.close();
            } catch (SQLException e) {
                // 记录日志但继续关闭连接
            }
        }

        if (conn != null) {
            conn.close();
        }
    }

    /**
     * 测试连接（用于验证配置）
     *
     * @param args 命令行参数
     */
    public static void main(String[] args) {
        System.out.println("=== 数据库连接测试 ===");
        System.out.println("主数据库URL: " + maskUrl(DB_URL));
        System.out.println("用户名: " + DB_USER);
        System.out.println("密码配置: " + (DB_PASSWORD.isEmpty() ? "未配置" : "已配置"));

        try {
            Connection conn = getConnection();
            System.out.println("✓ 主数据库连接成功");
            conn.close();
        } catch (Exception e) {
            System.err.println("✗ 主数据库连接失败: " + e.getMessage());
        }

        try {
            Connection conn = getConnection1();
            System.out.println("✓ 第二数据库连接成功");
            conn.close();
        } catch (Exception e) {
            System.err.println("✗ 第二数据库连接失败: " + e.getMessage());
        }
    }

    /**
     * 隐藏URL中的敏感信息
     */
    private static String maskUrl(String url) {
        if (url == null) return "null";
        // 隐藏URL中的密码部分
        return url.replaceAll("://[^:]*:[^@]*@", "://***:***@");
    }
}
