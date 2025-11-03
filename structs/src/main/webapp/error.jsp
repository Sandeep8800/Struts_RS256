<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - TTS Dashboard</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #f5f7fa;
            padding: 40px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .error-container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 600px;
            text-align: center;
        }

        .error-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }

        h1 {
            color: #e74c3c;
            margin-bottom: 20px;
        }

        .error-message {
            background: #ffeaa7;
            border-left: 4px solid #fdcb6e;
            padding: 15px;
            margin: 20px 0;
            text-align: left;
        }

        .btn {
            display: inline-block;
            padding: 10px 20px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-top: 20px;
        }

        .btn:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">⚠️</div>
        <h1>Oops! Something went wrong</h1>

        <s:if test="hasActionErrors()">
            <div class="error-message">
                <s:actionerror/>
            </div>
        </s:if>

        <s:else>
            <div class="error-message">
                <p>An unexpected error occurred while loading the dashboard.</p>
            </div>
        </s:else>

        <a href="dashboard" class="btn">← Back to Dashboard</a>
    </div>
</body>
</html>

