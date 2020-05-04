# serverless-pypi

pypi server based on s3 bucket with authentication using AWS Cognito.

# Usage
For example-deployment see: 
1. When deployed head to [Cognito](https://ap-northeast-1.console.aws.amazon.com/cognito/home?region=ap-northeast-1) 
and manage user pool `serverless-pypi-cognito-pool` and add a user. This user must first login and change its password.
1. Change users password using (If there is an error for too short password, change password policy)
    ```shell script
    aws --profile dev cognito-idp admin-set-user-password --user-pool-id <your user pool id> --username user1 --password password --permanent
    ```
1. Get the [API Gateway](https://ap-northeast-1.console.aws.amazon.com/apigateway/home?region=ap-northeast-1) 
URL from the `pypi-priv`-API by clicking on Stages and `simple`. You can see the invoke URL on top like: `https://API-ID.execute-api.ap-northeast-1.amazonaws.com/simple` 
1. Upload packages using `s3pypi`:  
    - `pip install s3pypi`
    - In your project-dir `s3pypi --profile dev --bucket sc-dev-serverless-pypi.example.com --private`
1. Download package using `pip install batmobile --index-url https://API-ID.execute-api.ap-northeast-1.amazonaws.com/simple`

# Open points
- Link IAM with Cognito user pool to enable all developers to upload files
- Or alternatively: Use api_authorization `IAM`

# Credits
Using modules:
- [terraform-aws-serverless-pypi](https://github.com/amancevice/terraform-aws-serverless-pypi)
- [terraform-aws-serverless-pypi-cognito](https://github.com/amancevice/terraform-aws-serverless-pypi-cognito)
