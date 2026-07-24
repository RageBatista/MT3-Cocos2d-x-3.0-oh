//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import org.apache.log4j.Logger;

public class HikariCPUtil {
    private static final Logger logger = Logger.getLogger(HikariCPUtil.class);

    public static Connection getConnection() throws SQLException {
        return HikariCPDataSourceManager.getInstance().getConnection();
    }

    public static void close(Connection conn, PreparedStatement pst, ResultSet rs) {
        closeResultSet(rs);
        closePreparedStatement(pst);
        closeConnection(conn);
    }

    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        closeResultSet(rs);
        closeStatement(stmt);
        closeConnection(conn);
    }

    public static void close(Connection conn, PreparedStatement pst) {
        closePreparedStatement(pst);
        closeConnection(conn);
    }

    public static void close(Connection conn, Statement stmt) {
        closeStatement(stmt);
        closeConnection(conn);
    }

    public static void close(Connection conn) {
        closeConnection(conn);
    }

    public static void close(ResultSet rs) {
        closeResultSet(rs);
    }

    public static void close(PreparedStatement pst) {
        closePreparedStatement(pst);
    }

    public static void close(Statement stmt) {
        closeStatement(stmt);
    }

    private static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                logger.error("Error closing database connection", e);
            }
        }

    }

    private static void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try {
                if (!rs.isClosed()) {
                    rs.close();
                }
            } catch (SQLException e) {
                logger.error("Error closing ResultSet", e);
            }
        }

    }

    private static void closePreparedStatement(PreparedStatement pst) {
        if (pst != null) {
            try {
                if (!pst.isClosed()) {
                    pst.close();
                }
            } catch (SQLException e) {
                logger.error("Error closing PreparedStatement", e);
            }
        }

    }

    private static void closeStatement(Statement stmt) {
        if (stmt != null) {
            try {
                if (!stmt.isClosed()) {
                    stmt.close();
                }
            } catch (SQLException e) {
                logger.error("Error closing Statement", e);
            }
        }

    }

    public static boolean testConnection() {
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        boolean result;
        try {
            conn = getConnection();
            pst = conn.prepareStatement("SELECT 1");
            rs = pst.executeQuery();
            boolean hasResult = rs.next();
            return hasResult;
        } catch (SQLException e) {
            logger.error("Database connection test failed", e);
            result = false;
        } finally {
            close(conn, pst, rs);
        }

        return result;
    }

    public static String getPoolStatus() {
        return HikariCPDataSourceManager.getInstance().getPoolStatus();
    }

    public static boolean isDataSourceAvailable() {
        return HikariCPDataSourceManager.getInstance().isAvailable();
    }

    public static HealthCheckResult performHealthCheck() {
        HealthCheckResult result = new HealthCheckResult();

        try {
            if (!isDataSourceAvailable()) {
                result.setHealthy(false);
                result.setMessage("DataSource is not available");
                return result;
            }

            long startTime = System.currentTimeMillis();
            boolean connectionTest = testConnection();
            long responseTime = System.currentTimeMillis() - startTime;
            result.setHealthy(connectionTest);
            result.setResponseTime(responseTime);
            result.setMessage(connectionTest ? "Database connection healthy" : "Database connection failed");
            result.setPoolStatus(getPoolStatus());
        } catch (Exception e) {
            result.setHealthy(false);
            result.setMessage("Health check failed: " + e.getMessage());
            logger.error("Database health check failed", e);
        }

        return result;
    }

    public static class HealthCheckResult {
        private boolean healthy;
        private String message;
        private long responseTime;
        private String poolStatus;

        public boolean isHealthy() {
            return this.healthy;
        }

        public void setHealthy(boolean healthy) {
            this.healthy = healthy;
        }

        public String getMessage() {
            return this.message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public long getResponseTime() {
            return this.responseTime;
        }

        public void setResponseTime(long responseTime) {
            this.responseTime = responseTime;
        }

        public String getPoolStatus() {
            return this.poolStatus;
        }

        public void setPoolStatus(String poolStatus) {
            this.poolStatus = poolStatus;
        }

        public String toString() {
            return String.format("HealthCheck{healthy=%s, message='%s', responseTime=%dms, poolStatus='%s'}", this.healthy, this.message, this.responseTime, this.poolStatus);
        }
    }
}
