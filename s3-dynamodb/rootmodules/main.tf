
module "S3" {
    source                   = "../child-modules/s3"
    bucket                   = var.bucket 
  
}

module "dynamoDB" {
    source                  = "../child-modules/dynamodb"
    db-name                 = var.db-name
    billing_mode            = var.billing_mode
    type                    = var.type
    hash_key                = var.hash_key   
}