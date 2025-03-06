terraform {
  backend "gcs" {
    bucket = var.bucket.name
    prefix = var.bucket.prefix
  }
}

