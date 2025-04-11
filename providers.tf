terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.94.1"
        }
    }
}

# Configure the AWS Provider
provider "aws" {

    # Use credentials from AWS SSO
    # Use "AWS SSO" tile in Okta to log in and get to the "AWS access portal" page
    # Click on the account in the list and click on "Access keys"
    # Get the SSO start URL and region from under the "AWS IAM Identity Center credentials (Recommended)" heading
    # Run `aws configure sso`
    # Provide:
    # SSO session name (Recommended): tf
    # SSO start URL [None]: https://<your-AWS-SSO-portal-here>.awsapps.com/start/#
    # SSO region [None]: <your-AWS-SSO-region-here> # Note: not necessarily the same region your instances are in
    # SSO registration scopes [sso:account:access]: # Leave empty
    # Then the AWS CLI opens the browser, click the buttons, close the tab
    # See "There are x AWS accounts available to you." in the CLI
    # Use your keyboard arrows to select the account and role
    # CLI default client Region [None]: Use the AWS region your instances are in, should match this var:
    region = var.region
    # CLI default output format [None]: # Leave empty
    # CLI profile name [<role>-<AWS-account-number>]: tf # This is the value to provide into the profile variable here
    profile = "tf"

    default_tags {
        tags = {
            Name = var.name_tag
            Repo = var.repo_tag
            tf_last_deployed = var.tf_last_deployed
        }
    }
}
