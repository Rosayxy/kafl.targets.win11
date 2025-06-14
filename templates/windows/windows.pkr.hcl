# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}


# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "autounattend" {
  type    = string
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "disk_size" {
  type    = string
  default = "65536"
}

variable "headless" {
  type = bool
  default = true
}

variable "iso_checksum" {
  type = string
}

variable "iso_checksum_type" {
  type = string
}

variable "iso_url" {
  type = string
}

variable "memory" {
  type    = string
  default = "8192"
}

variable "vm_name" {
  type    = string
  default = "win7x64"
}

variable "winrm_password" {
  type    = string
  default = "vagrant"
}

variable "winrm_timeout" {
  type    = string
  default = "8h"
}

variable "winrm_username" {
  type    = string
  default = "vagrant"
}

variable "https_proxy" {
  type    = string
  default = env("https_proxy")
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "qemu" "windows" {
  accelerator      = "kvm"
  boot_wait        = "5s"
  communicator     = "winrm"
  cpus             = "${var.cpus}"
  disk_compression = false
  disk_interface   = "ide"
  disk_size        = "${var.disk_size}"
  floppy_files     = ["${var.autounattend}", "scripts/fixnetwork.ps1", "scripts/setup_winrm_public.bat"]
  format           = "qcow2"
  headless         = "${var.headless}"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  qemuargs         = [
    ["-usb"],
    ["-device", "usb-tablet"],
    ["-drive", "if=pflash,format=raw,unit=0,file=/home/mimi/tmp2/kAFL/code.img" ],
    ["-drive", "if=pflash,format=raw,unit=1,file=/home/mimi/tmp2/kAFL/efivars.img" ],
    ["-drive", "file=/home/mimi/.cache/packer/c7a6dd5c537a710fa9be2731dfec58b7361557e0.iso,media=cdrom,if=none,id=cd0"],
    ["-device", "ide-cd,drive=cd0"],
    ["-cpu", "host"],
    ["-drive", "file=/home/mimi/tmp2/kAFL/kafl/examples/templates/windows/output-windows_1/${var.vm_name}.qcow2,if=ide,cache=writeback,discard=ignore,format=qcow2"]
  ]
  net_device       = "rtl8139"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_compaction  = true
  vm_name          = "${var.vm_name}.qcow2"
  vnc_bind_address = "0.0.0.0"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_username   = "${var.winrm_username}"
  # do not check server certificate chain and host name
  winrm_insecure   = true
  # use HTTP
  winrm_use_ssl    = false
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.qemu.windows"]

  provisioner "ansible" {
    playbook_file = "playbook.yml"
    user = "${var.winrm_username}"
    use_proxy = false
    extra_arguments = [
      "-e", "ansible_winrm_scheme=http",
      "-e", "ansible_proxy=${var.https_proxy}",
      "-v"
    ]
  }
  post-processor "shell-local" {
    inline = [
      "rm -rf /home/mimi/tmp2/kAFL/kafl/examples/templates/windows/output-windows",
      "mkdir /home/mimi/tmp2/kAFL/kafl/examples/templates/windows/output-windows",
      "cp /home/mimi/tmp2/kAFL/kafl/examples/templates/windows/output-windows_1/win10.qcow2 /home/mimi/tmp2/kAFL/kafl/examples/templates/windows/output-windows",
      "echo ",
    ]
  }
  post-processor "vagrant" {
    vagrantfile_template = "Vagrantfile_template"
  } 
}
