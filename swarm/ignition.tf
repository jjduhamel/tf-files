data "ignition_user" "core" {
  name = "core"
  no_create_home = true
  groups = [ "wheel", "docker", "systemd-journal" ]
  ssh_authorized_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTuzO36B6UJ+ffFyl6Q/C0niFU9IjSeiKR/8UD72VK2TgiqPloCMWnA4/pxja1TRpwBXCdiDpdWmHhFbhFxv8V+d6iS9f2z1iwIJ5PW636VZPj+GWNbpWpIoD/fZcUxQ0tNjc0JyVHv2AVgnmisOtmEaZQMj1vjpBOe30oIzYQRIq6E/7vEIzahTwZ+23XJgk6z8wDm0+9oRM7AKaZxFktakOygHjY6Twx2EFqjF1JtfhLb8EjURJNSPnnOUrAqfQRjSr7uMc9pd3mqtdeIDorgwdCvQKU84NL9TQEQAZSqdPXdMv5wyz12YR6btK8jGTSxeRHKVAcNIhW0kQhlOvT jjd@emigrant",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/h8WE8vZZel6QVmsxWj9pw81KFIfa84/WAoEZqwtSChzKw9B5rEz1EAIXRd97bL/Q8uVTOjUFgbaUG8ibr4zHhGt6WApf2ACha1j0m3NsKRpFLFpZOuzah/9bECk5TGloWwvi0ka7A+gwd4OaZsbN6ntjM6RNMoL9XAio+gN7UEg6rF5nE8UJyHEACSxm4VUKIYzeXatLOJlDMRq+waiuVKbNN8VoOIJf4FdlBixzWFI9uG7v5xY+t40ttB7ZMCCY2FegXazsFXvsjhA00dZlPIHxZ6QAgyri14uZMLrRY85PvOqYOFHRsw+pX5/8PlNsfcTxibEhx9bo57ip4czb jjd@tram"
  ]
}

data "ignition_user" "jjd" {
  name = "jjd"
  groups = [ "wheel", "sudo", "docker", "systemd-journal" ]
  ssh_authorized_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTuzO36B6UJ+ffFyl6Q/C0niFU9IjSeiKR/8UD72VK2TgiqPloCMWnA4/pxja1TRpwBXCdiDpdWmHhFbhFxv8V+d6iS9f2z1iwIJ5PW636VZPj+GWNbpWpIoD/fZcUxQ0tNjc0JyVHv2AVgnmisOtmEaZQMj1vjpBOe30oIzYQRIq6E/7vEIzahTwZ+23XJgk6z8wDm0+9oRM7AKaZxFktakOygHjY6Twx2EFqjF1JtfhLb8EjURJNSPnnOUrAqfQRjSr7uMc9pd3mqtdeIDorgwdCvQKU84NL9TQEQAZSqdPXdMv5wyz12YR6btK8jGTSxeRHKVAcNIhW0kQhlOvT jjd@emigrant",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/h8WE8vZZel6QVmsxWj9pw81KFIfa84/WAoEZqwtSChzKw9B5rEz1EAIXRd97bL/Q8uVTOjUFgbaUG8ibr4zHhGt6WApf2ACha1j0m3NsKRpFLFpZOuzah/9bECk5TGloWwvi0ka7A+gwd4OaZsbN6ntjM6RNMoL9XAio+gN7UEg6rF5nE8UJyHEACSxm4VUKIYzeXatLOJlDMRq+waiuVKbNN8VoOIJf4FdlBixzWFI9uG7v5xY+t40ttB7ZMCCY2FegXazsFXvsjhA00dZlPIHxZ6QAgyri14uZMLrRY85PvOqYOFHRsw+pX5/8PlNsfcTxibEhx9bo57ip4czb jjd@tram"
  ]
}

data "ignition_systemd_unit" "docker-tcp" {
  name = "docker-tcp.socket"
  enable = true
  content = "${ file("${ path.module }/fs/docker-tcp.socket") }"
}

data "ignition_config" "swarm" {
  systemd = [
    "${ data.ignition_systemd_unit.docker-tcp.id }"
  ]

  users = [
    "${ data.ignition_user.core.id }",
    "${ data.ignition_user.jjd.id }"
  ]
}
