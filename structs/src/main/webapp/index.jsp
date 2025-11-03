<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TTS Dashboard - Superset Integration</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            height: 100%;
            width: 100%;
            overflow: hidden;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        .header {
            display: none; /* Hidden for full-screen mode */
        }

        .content {
            height: 100vh;
            width: 100vw;
            padding: 0;
            background: #fff;
            position: relative;
        }

        #dashboard-container {
            height: 100%;
            width: 100%;
            background: white;
            overflow: hidden;
        }

        /* Hide Superset sidebar and navigation elements */
        #dashboard-container iframe {
            border: none;
            width: 100%;
            height: 100%;
        }

        /* Force hide Superset's left sidebar */
        #dashboard-container [data-test="dashboard-content"] {
            margin-left: 0 !important;
        }

        /* Additional CSS to hide any Superset UI elements */
        #dashboard-container .dashboard-header,
        #dashboard-container .dashboard-builder-sidepane,
        #dashboard-container .dashboard-component-tabs {
            display: none !important;
        }

        /* Nuclear option - force hide all Superset navigation and chrome */
        #dashboard-container [class*="LeftNav"],
        #dashboard-container [class*="menu"],
        #dashboard-container [class*="SideNav"],
        #dashboard-container [class*="sidebar"],
        #dashboard-container .dashboard-builder-sidepane,
        #dashboard-container .header-with-actions,
        #dashboard-container nav {
            display: none !important;
            width: 0 !important;
            opacity: 0 !important;
        }

        /* Force dashboard content to full width */
        #dashboard-container .dashboard-content,
        #dashboard-container [data-test="dashboard-content"] {
            margin-left: 0 !important;
            padding-left: 0 !important;
            width: 100% !important;
        }

        .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: #555;
            font-size: 16px;
            z-index: 1000;
        }

        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .error {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #e74c3c;
            text-align: center;
            padding: 30px;
            background-color: #fff;
            border: 2px solid #e74c3c;
            border-radius: 8px;
            display: none;
            z-index: 1000;
            max-width: 500px;
        }

        .error h3 {
            margin-bottom: 10px;
            font-size: 20px;
        }

        .error-details {
            font-size: 14px;
            color: #666;
            margin-top: 10px;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 4px;
            font-family: monospace;
        }

        .controls {
            display: none; /* Hidden for full-screen mode */
        }

        /* Floating control button (optional - for refresh functionality) */
        .floating-controls {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 999;
            display: none; /* Hidden by default, show on hover */
        }

        body:hover .floating-controls {
            display: block;
        }

        .btn {
            padding: 10px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s;
            margin-left: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        }

        .btn-secondary {
            background: #95a5a6;
            color: white;
        }

        .btn-secondary:hover {
            background: #7f8c8d;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        }
    </style>
</head>
<body>
    <!-- Header hidden for full-screen mode -->

    <s:if test="hasActionErrors()">
        <div class="error" style="display: block;">
            <h3>⚠️ Action Error</h3>
            <s:actionerror/>
        </div>
    </s:if>

    <div class="content">
        <div id="loading" class="loading">
            <div class="spinner"></div>
            <p>Loading Superset dashboard...</p>
            <small style="color: #999; margin-top: 10px;">Initializing Embedded SDK</small>
        </div>

        <div id="error" class="error">
            <h3>⚠️ Error Loading Dashboard</h3>
            <p id="error-message"></p>
            <div class="error-details" id="error-details"></div>
        </div>

        <div id="dashboard-container"></div>
    </div>

    <!-- Optional floating controls (appear on hover) -->
    <div class="floating-controls">
        <button class="btn btn-secondary" onclick="refreshToken()" title="Refresh Token">🔄</button>
        <button class="btn btn-primary" onclick="reloadDashboard()" title="Reload Dashboard">↻</button>
    </div>

    <!-- Superset Embedded SDK -->
    <script src="https://unpkg.com/@superset-ui/embedded-sdk@0.1.0-alpha.10/bundle/index.js"></script>

    <script>
        // Configuration from JSP/Struts
        const config = {
            guestToken: '${guestToken}',
            baseUrl: '${baseUrl}',
            dashboardId: '${dashboardId}',
            tokenRefreshInterval: 50 * 60 * 1000 // Refresh every 50 minutes
        };

        // Elements
        const loadingElement = document.getElementById('loading');
        const errorElement = document.getElementById('error');
        const errorMessageElement = document.getElementById('error-message');
        const errorDetailsElement = document.getElementById('error-details');
        const containerElement = document.getElementById('dashboard-container');

        let tokenRefreshTimer;
        let embeddedDashboard = null;

        /**
         * Embed Superset dashboard using the official Embedded SDK
         */
        async function embedSupersetDashboard() {
            try {
                console.log('🚀 Starting Superset dashboard embed...');
                console.log('Dashboard ID:', config.dashboardId);
                console.log('Base URL:', config.baseUrl);
                console.log('Guest Token (first 20 chars):', config.guestToken.substring(0, 20) + '...');

                // Show loading
                loadingElement.style.display = 'flex';
                errorElement.style.display = 'none';
                containerElement.style.display = 'block';

                // Validate configuration
                if (!config.guestToken || config.guestToken === '') {
                    throw new Error('Guest token is missing or empty');
                }

                if (!config.dashboardId || config.dashboardId === '') {
                    throw new Error('Dashboard ID is missing or empty');
                }

                if (!config.baseUrl || config.baseUrl === '') {
                    throw new Error('Superset base URL is missing or empty');
                }

                // Embed the dashboard using Superset Embedded SDK
                embeddedDashboard = await supersetEmbeddedSdk.embedDashboard({
                    id: config.dashboardId,
                    supersetDomain: config.baseUrl,
                    mountPoint: containerElement,
                    fetchGuestToken: () => config.guestToken,
                    dashboardUiConfig: {
                        hideTitle: true,           // Hide dashboard title
                        hideChartControls: true,   // Hide chart controls
                        hideTab: true,             // Hide tabs
                        filters: {
                            expanded: false,       // Collapse filters
                            visible: false         // Hide filter bar
                        }
                    }
                });

                console.log('✅ Dashboard embedded successfully!');

                // Hide loading
                loadingElement.style.display = 'none';

                // Setup automatic token refresh
                setupTokenRefresh();

            } catch (error) {
                console.error('❌ Error embedding Superset dashboard:', error);

                // Hide loading, show error
                loadingElement.style.display = 'none';
                errorElement.style.display = 'block';
                containerElement.style.display = 'none';

                errorMessageElement.textContent = error.message || 'Failed to load dashboard';
                errorDetailsElement.textContent = 'Check browser console for detailed error information.';

                // Log detailed error info
                console.error('Error details:', {
                    message: error.message,
                    stack: error.stack,
                    config: config
                });
            }
        }

        /**
         * Refresh the guest token via AJAX call to Struts action
         */
        async function refreshToken() {
            console.log('🔄 Refreshing guest token...');

            try {
                const response = await fetch('refreshToken', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });

                if (!response.ok) {
                    throw new Error('HTTP error! status: ' + response.status);
                }

                const data = await response.json();

                if (data.success && data.token) {
                    console.log('✅ Token refreshed successfully');
                    config.guestToken = data.token;


                    // Note: With Embedded SDK, the dashboard automatically uses the new token
                    // from the fetchGuestToken callback
                    console.log('ℹ️ Dashboard will use new token on next request');
                } else {
                    throw new Error(data.error || 'Token refresh failed');
                }
            } catch (error) {
                console.error('❌ Error refreshing token:', error);
                alert('Failed to refresh token: ' + error.message);
            }
        }

        /**
         * Reload the dashboard (re-embed)
         */
        function reloadDashboard() {
            console.log('↻ Reloading dashboard...');

            // Clear the container
            containerElement.innerHTML = '';

            // Re-embed
            embedSupersetDashboard();
        }

        /**
         * Setup automatic token refresh
         */
        function setupTokenRefresh() {
            // Clear existing timer if any
            if (tokenRefreshTimer) {
                clearInterval(tokenRefreshTimer);
            }

            // Set up periodic token refresh
            tokenRefreshTimer = setInterval(function() {
                console.log('⏰ Auto-refreshing token...');
                refreshToken();
            }, config.tokenRefreshInterval);

            console.log('✅ Token auto-refresh configured for every', config.tokenRefreshInterval / 60000, 'minutes');
        }

        /**
         * Initialize dashboard on page load
         */
        window.addEventListener('load', function() {
            console.log('📄 Page loaded, initializing dashboard...');
            embedSupersetDashboard();
        });

        /**
         * Cleanup on page unload
         */
        window.addEventListener('beforeunload', function() {
            if (tokenRefreshTimer) {
                clearInterval(tokenRefreshTimer);
                console.log('🧹 Cleanup: Token refresh timer cleared');
            }
        });
    </script>
</body>
</html>

