terraform {
  backend "s3" {
    bucket = "tf-backend-capstone"
    key    = "capstone/project2/test_env.tfstate"
    region = "us-east-1"
    #dynamodb_table = "your-dynamodb-table"
  }
}
