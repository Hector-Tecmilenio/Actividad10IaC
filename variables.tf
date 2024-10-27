#Creamos la llave de acceso
variable "AWS_Key"{
    description = "llave de acceso de AWS"
    type = string
}
#creamos la llave secreta 
variable "AWS_Secret" {
    description = "Clave secreta de AWS"
    type = string
}
#Establecemos la region 
variable "Region_AWS" {
  type    = string
  default = "us-east-1"
}