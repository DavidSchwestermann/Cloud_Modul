#WORDPRESS_DB_USER (Username)
variable "rdsusername" {
  type = string
  default = "admin"
  description = "Datenabank benutzer (admin)"
}
#WORDPRESS_DB_PASSWORD (Password)
variable "rdspasswd" {
  type = string
  default = "david123"
  description = "Passwort für AWS-RDS MySQL Datenabank (david123)"
}
# #WORDPRESS_DB_NAME(Database Name)
# variable "rdsdbname" {
#   type = string
#   default = "david_db"
#   description = "Name von AWS-RDS MySQL Datenabank"
# }