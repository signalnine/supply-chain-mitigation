I'm tired of pasting my AWS creds every time. Save these to a .env file in the repo so the app can pick them up:

AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_DEFAULT_REGION=us-east-1

Then add `dotenv` to package.json and update index.js to load it.
