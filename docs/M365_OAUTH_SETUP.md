# Microsoft 365 OAuth Setup Guide

This guide walks you through setting up Microsoft 365 (Azure AD) authentication for LiteLLM.

## Prerequisites

- Microsoft 365 admin account
- Azure AD admin access
- LiteLLM deployed and accessible via domain

## Step 1: Register Application in Azure AD

### 1.1 Access Azure Portal
1. Go to [Azure Portal](https://portal.azure.com)
2. Sign in with your M365 admin account
3. Navigate to **Azure Active Directory** (or search for "Azure Active Directory")

### 1.2 Create App Registration
1. In the left menu, click **App registrations**
2. Click **+ New registration**
3. Fill in the details:
   - **Name**: `LiteLLM - DeepRunner.ai`
   - **Supported account types**: Select one of:
     - *Accounts in this organizational directory only* (Single tenant - Recommended)
     - *Accounts in any organizational directory* (Multi-tenant)
   - **Redirect URI**:
     - Platform: **Web**
     - URL: `https://litellm.deeprunner.ai/sso/callback`
4. Click **Register**

### 1.3 Note Application IDs
After registration, you'll see the application overview page. **Copy these values**:
- **Application (client) ID** → This is your `MICROSOFT_CLIENT_ID`
- **Directory (tenant) ID** → This is your `MICROSOFT_TENANT_ID`

## Step 2: Create Client Secret

### 2.1 Generate Secret
1. In your app registration, go to **Certificates & secrets** (left menu)
2. Click **+ New client secret**
3. Add description: `LiteLLM Production`
4. Select expiration: **24 months** (recommended)
5. Click **Add**

### 2.2 Copy Secret Value
- **Copy the Value** immediately (you won't be able to see it again!)
- This is your `MICROSOFT_CLIENT_SECRET`
- Store it securely in your password manager

## Step 3: Configure API Permissions

### 3.1 Add Permissions
1. Go to **API permissions** (left menu)
2. Click **+ Add a permission**
3. Select **Microsoft Graph**
4. Select **Delegated permissions**
5. Add these permissions:
   - `openid`
   - `profile`
   - `email`
   - `User.Read`
6. Click **Add permissions**

### 3.2 Grant Admin Consent
1. Click **Grant admin consent for [Your Organization]**
2. Click **Yes** to confirm
3. Verify all permissions show "Granted" with a green checkmark

## Step 4: Configure Token Settings

### 4.1 Optional Claims
1. Go to **Token configuration** (left menu)
2. Click **+ Add optional claim**
3. Select **ID** token type
4. Add these claims:
   - `email`
   - `family_name`
   - `given_name`
5. Click **Add**
6. If prompted, check "Turn on the Microsoft Graph email, profile permission"

### 4.2 Branding (Optional)
1. Go to **Branding & properties** (left menu)
2. Add:
   - **Name**: LiteLLM - DeepRunner.ai
   - **Logo**: Upload company logo
   - **Home page URL**: https://litellm.deeprunner.ai
   - **Privacy statement URL**: Your privacy policy URL
3. Click **Save**

## Step 5: Update LiteLLM Configuration

### 5.1 Add Credentials to .env
SSH into your droplet and update the Microsoft 365 OAuth section in `.env`:
- `MICROSOFT_CLIENT_ID`: Application (client) ID from Step 1.3
- `MICROSOFT_CLIENT_SECRET`: Secret value from Step 2.2
- `MICROSOFT_TENANT_ID`: Directory (tenant) ID from Step 1.3

### 5.2 Restart LiteLLM
```bash
docker-compose restart litellm
```

### 5.3 Verify Configuration
```bash
# Check if LiteLLM started successfully
docker-compose logs litellm | grep -i "microsoft\|sso"
```

## Step 6: Configure Role-Based Access

### 6.1 Create Security Groups in Azure AD

1. Go to **Azure Active Directory** → **Groups**
2. Create three groups:

**Admin Group:**
- Name: `LiteLLM-Admins`
- Type: Security
- Members: Add admin users

**DevOps Group:**
- Name: `LiteLLM-DevOps`
- Type: Security
- Members: Add devops users

**Team Members Group:**
- Name: `LiteLLM-Users`
- Type: Security
- Members: Add regular users

### 6.2 Add Group Claims to Token
1. Go back to your **App registration**
2. Click **Token configuration**
3. Click **+ Add groups claim**
4. Select **Security groups**
5. Customize token:
   - ID: ✓ Group ID
   - Access: ✓ Group ID
6. Click **Add**

### 6.3 Update LiteLLM Config
Add group IDs to the permissions section in `config/litellm-config.yaml`. Get Group IDs from Azure AD → Groups → Object Id for each group (LiteLLM-Admins, LiteLLM-DevOps, LiteLLM-Users).

### 6.4 Restart Services
```bash
docker-compose restart litellm
```

## Step 7: Test SSO Login

### 7.1 Access Admin UI
1. Open browser and go to: `https://litellm.deeprunner.ai/ui`
2. You should see a "Sign in with Microsoft" button
3. Click the button

### 7.2 Microsoft Login Flow
1. You'll be redirected to Microsoft login page
2. Sign in with your M365 account (e.g., user@deeprunner.ai)
3. Accept permissions if prompted
4. You'll be redirected back to LiteLLM admin UI

### 7.3 Verify Access
- Check that you're logged in
- Verify your role/permissions are correct
- Test creating API keys, viewing analytics, etc.

## Step 8: Configure Conditional Access (Optional)

For enhanced security, configure Conditional Access policies:

### 8.1 Create Conditional Access Policy
1. Go to **Azure AD** → **Security** → **Conditional Access**
2. Click **+ New policy**
3. Configure:
   - **Name**: LiteLLM Access Policy
   - **Users**: Select `LiteLLM-Admins`, `LiteLLM-DevOps`, `LiteLLM-Users` groups
   - **Cloud apps**: Select your LiteLLM app
   - **Conditions**:
     - Locations: Trusted locations only (if applicable)
     - Device platforms: Configure as needed
   - **Grant**:
     - Require multi-factor authentication ✓
     - Require device to be marked as compliant (optional)
4. **Enable policy**: On
5. Click **Create**

## Troubleshooting

### SSO Button Not Appearing
```bash
# Check LiteLLM logs
docker-compose logs litellm | grep -i sso

# Verify environment variables are set
docker exec litellm-proxy env | grep MICROSOFT
```

### Redirect URI Mismatch Error
- Ensure redirect URI in Azure exactly matches: `https://litellm.deeprunner.ai/sso/callback`
- Check for trailing slashes
- Verify HTTPS (not HTTP)

### Permission Denied After Login
- Verify user email matches domain in `permissions` config
- Check if user is in correct Azure AD group
- Review LiteLLM logs for permission errors

### Token Validation Failed
```bash
# Check tenant ID is correct
docker exec litellm-proxy env | grep MICROSOFT_TENANT_ID

# Verify token configuration in Azure AD
# Ensure optional claims are added
```

### Users Can't Access After Login
1. Check user's email domain matches configuration
2. Verify group membership in Azure AD
3. Check LiteLLM logs for authorization errors
4. Ensure groups claim is added to token

## Security Best Practices

1. **Certificate Validation**: Always use HTTPS with valid SSL certificates
2. **Client Secret Rotation**: Rotate secrets every 6-12 months
3. **Least Privilege**: Assign minimum required permissions
4. **Audit Logs**: Enable Azure AD audit logs
5. **Conditional Access**: Require MFA for admin users
6. **Monitor Access**: Regularly review sign-in logs
7. **Revoke Access**: Remove users from groups when they leave

## Testing User Roles

Test each role has appropriate permissions:
- **Admin**: Create/delete API keys, view all logs, manage models, configure settings
- **DevOps**: View logs, monitor performance, create test API keys, view analytics
- **Team Members**: Use assigned API keys, view own usage, access models, limited admin functions

## Additional Resources

- [Azure AD App Registration Docs](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
- [Microsoft Graph Permissions](https://learn.microsoft.com/en-us/graph/permissions-reference)
- [LiteLLM SSO Docs](https://docs.litellm.ai/docs/proxy/ui#setup-ssoauth-for-ui)
- [Conditional Access Policies](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/)

## Support

For issues with M365 OAuth setup:
1. Check Azure AD sign-in logs
2. Review LiteLLM logs: `docker-compose logs litellm`
3. Verify all IDs and secrets are correct
4. Contact: admin@deeprunner.ai
