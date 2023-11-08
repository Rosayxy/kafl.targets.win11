SHELL := /bin/bash

CUR_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOT_DIR := $(CUR_DIR)/../

$(ROOT_DIR)/venv/bin/ansible-playbook:
	python3 -m venv $(ROOT_DIR)/venv
	$(ROOT_DIR)/venv/bin/python -m pip install ansible==6.7.0 pywinrm

ansible: $(ROOT_DIR)/venv/bin/ansible-playbook

init:
	vagrant up --no-provision 
	vagrant snapshot save --force 'ready_provision'
	
revoke:
	vagrant snapshot restore 'ready_provision'
gui:
	vagrant up --no-provision
	virt-viewer -a -c qemu:///session vagrant-kafl-windows

compile:
	mkdir -p bin/{userspace,driver}
	x86_64-w64-mingw32-gcc src/userspace/selffuzz_test.c -I ../ -o bin/userspace/selffuzz_test.exe -Wall -mwindows 
	x86_64-w64-mingw32-gcc src/driver/vuln_test.c -I ../ -o bin/driver/vuln_test.exe -Wall -lntdll -lpsapi

target: compile ansible
	vagrant up --no-provision
	TARGET_HARNESS='provision_target' vagrant provision
	vagrant halt


no_target: compile ansible
	vagrant up --no-provision --debug
	vagrant provision
