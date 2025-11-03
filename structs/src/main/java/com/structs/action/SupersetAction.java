package com.structs.action;

import com.opensymphony.xwork2.ActionSupport;
import com.structs.config.SupersetConfig;
import com.structs.util.GuestTokenUtil;

import java.util.*;

/**
 * Struts2 Action for handling Superset dashboard embedding with Guest Token authentication
 */
public class SupersetAction extends ActionSupport {

    private String guestToken;
    private String baseUrl;
    private String dashboardId;
    private boolean success;
    private String error;
    private TokenInfo tokenInfo;

    /**
     * Show dashboard - Load dashboard with guest token
     */
    public String showDashboard() {
        try {
            SupersetConfig config = SupersetConfig.getInstance();

            // Generate guest token using RS256
            this.guestToken = GuestTokenUtil.createGuestTokenForDashboard(config.getDashboardId());
            this.baseUrl = config.getBaseUrl();
            this.dashboardId = config.getDashboardId();

            System.out.println("✅ Guest token generated successfully");
            System.out.println("Dashboard ID: " + dashboardId);
            System.out.println("Base URL: " + baseUrl);

            return SUCCESS;

        } catch (Exception e) {
            e.printStackTrace();
            addActionError("Failed to generate guest token: " + e.getMessage());
            return ERROR;
        }
    }

    /**
     * Default action - redirect to showDashboard
     */
    public String execute() {
        return showDashboard();
    }

    /**
     * Get guest token action - Generate guest token via AJAX
     */
    public String getGuestTokenAction() {
        try {
            SupersetConfig config = SupersetConfig.getInstance();

            // Generate guest token
            String newToken = GuestTokenUtil.createGuestTokenForDashboard(config.getDashboardId());

            // Prepare response
            this.success = true;
            this.guestToken = newToken;
            this.tokenInfo = new TokenInfo(newToken, System.currentTimeMillis() + config.getTokenTtl());

            System.out.println("✅ Guest token generated via AJAX");

            return SUCCESS;

        } catch (Exception e) {
            e.printStackTrace();
            this.success = false;
            this.error = e.getMessage();
            return ERROR;
        }
    }

    /**
     * Refresh token action - Generate new guest token via AJAX
     */
    public String refreshToken() {
        try {
            SupersetConfig config = SupersetConfig.getInstance();

            // Generate new guest token
            String newToken = GuestTokenUtil.createGuestTokenForDashboard(config.getDashboardId());

            // Prepare response
            this.success = true;
            this.guestToken = newToken;
            this.tokenInfo = new TokenInfo(newToken, System.currentTimeMillis() + config.getTokenTtl());

            System.out.println("✅ Token refreshed successfully");

            return SUCCESS;

        } catch (Exception e) {
            e.printStackTrace();
            this.success = false;
            this.error = e.getMessage();
            this.tokenInfo = new TokenInfo(null, 0);
            return ERROR;
        }
    }

    // Getters and Setters
    public String getGuestToken() {
        return guestToken;
    }

    public void setGuestToken(String guestToken) {
        this.guestToken = guestToken;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public String getDashboardId() {
        return dashboardId;
    }

    public void setDashboardId(String dashboardId) {
        this.dashboardId = dashboardId;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public TokenInfo getTokenInfo() {
        return tokenInfo;
    }

    public void setTokenInfo(TokenInfo tokenInfo) {
        this.tokenInfo = tokenInfo;
    }

    /**
     * Token information for JSON responses
     */
    public static class TokenInfo {
        private String token;
        private long expiresAt;

        public TokenInfo(String token, long expiresAt) {
            this.token = token;
            this.expiresAt = expiresAt;
        }

        public String getToken() {
            return token;
        }

        public void setToken(String token) {
            this.token = token;
        }

        public long getExpiresAt() {
            return expiresAt;
        }

        public void setExpiresAt(long expiresAt) {
            this.expiresAt = expiresAt;
        }
    }
}

