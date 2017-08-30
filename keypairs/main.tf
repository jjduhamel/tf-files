provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "hbpcb-terraform"
    key = "keypairs/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_key_pair" "jjd-emigrant" {
  key_name = "jjd-emigrant"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTuzO36B6UJ+ffFyl6Q/C0niFU9IjSeiKR/8UD72VK2TgiqPloCMWnA4/pxja1TRpwBXCdiDpdWmHhFbhFxv8V+d6iS9f2z1iwIJ5PW636VZPj+GWNbpWpIoD/fZcUxQ0tNjc0JyVHv2AVgnmisOtmEaZQMj1vjpBOe30oIzYQRIq6E/7vEIzahTwZ+23XJgk6z8wDm0+9oRM7AKaZxFktakOygHjY6Twx2EFqjF1JtfhLb8EjURJNSPnnOUrAqfQRjSr7uMc9pd3mqtdeIDorgwdCvQKU84NL9TQEQAZSqdPXdMv5wyz12YR6btK8jGTSxeRHKVAcNIhW0kQhlOvT jjd@emigrant"
}

resource "aws_key_pair" "jjd-tram" {
  key_name = "jjd-tram"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/h8WE8vZZel6QVmsxWj9pw81KFIfa84/WAoEZqwtSChzKw9B5rEz1EAIXRd97bL/Q8uVTOjUFgbaUG8ibr4zHhGt6WApf2ACha1j0m3NsKRpFLFpZOuzah/9bECk5TGloWwvi0ka7A+gwd4OaZsbN6ntjM6RNMoL9XAio+gN7UEg6rF5nE8UJyHEACSxm4VUKIYzeXatLOJlDMRq+waiuVKbNN8VoOIJf4FdlBixzWFI9uG7v5xY+t40ttB7ZMCCY2FegXazsFXvsjhA00dZlPIHxZ6QAgyri14uZMLrRY85PvOqYOFHRsw+pX5/8PlNsfcTxibEhx9bo57ip4czb jjd@tram"
}
