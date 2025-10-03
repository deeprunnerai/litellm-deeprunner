#!/bin/bash
# Set admin role for gaurav@deeprunner.ai

echo "Setting admin role for gaurav@deeprunner.ai..."

docker compose exec -T postgres psql -U litellm_user -d litellm <<EOF
UPDATE "LiteLLM_UserTable"
SET user_role = 'proxy_admin'
WHERE user_email = 'gaurav@deeprunner.ai';

SELECT user_email, user_role
FROM "LiteLLM_UserTable"
WHERE user_email = 'gaurav@deeprunner.ai';
EOF

echo "Done!"
