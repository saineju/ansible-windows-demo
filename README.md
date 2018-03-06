# Windows management with Ansible demo
This demo creates a simple AWS environment with one Windows 2016 server and configures it to allow access with WinRM.
The demo is designed to work with AWS free tier, so it should be safe to try out with own AWS account.

As this is designed to be a demo, there are compromises that are not acceptable in production like environment, such as
saving certificate key passwords as plain text and the running tasks will show account passwords as plain text also.

# Prerequisities
Before using one is expected to have
* Python (2.7 or 3.x)
  * https://www.python.org/
* virtualenv
  * https://virtualenv.pypa.io/en/stable/installation/
* AWS account
  * https://aws.amazon.com/free/
* AWS access keys
  * https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/
* awscli setup done
  * https://docs.aws.amazon.com/rekognition/latest/dg/setup-awscli.html

# How to use
1. Prepare environment: 
    ```bash setup_local_env.sh```
2. Run master playbook: 
    ```AWS_PROFILE=<your profile name> ansible-playbook -i inventories/demo.yml site.yml```

# What does it do exactly?
The first step will prepare your local environment, so it will create virtualenv and installs there required plugins (see files/requirements.txt for list).
It will also configure ansible to use python from virtualenv as its interpreter for localhost tasks, as it would otherwise try to use global python instead.

All files created for this demo will be created to the Git directory.

## Creating CA
The playbook will start by creating a CA to be used for signing certificates for TLS encrypting the traffic and provide client identification.
The CA will be created to the root of this Git repository by default and will be ignored by Git.

## Setuping the AWS environment
After the CA is done, a ssh key with name winrm-demo will be created to AWS, private key will be saved to ca -directory
After that script will create a VPC with one public subnet and t2.micro Windows 2016 instance to your AWS account. By default access is allowed to following ports
* Remote Desktop, 3389 - Restricted to currently available public IP
* WinRM HTTP, 5985 - Restricted to currently available public IP
* WinRM HTTPS, 5986 - Restricted to currently available public IP
* HTTP, 80 - Open from anywhere
* HTTPS, 443 - Open from anywhere

The currently available public IP will be checked from https://api.ipify.org/

When creating the machine, a user-data script is run on the server to enable WinRM and open access to both WinRM ports from currently available public IP.
After the server is up and running Windows server password is fetched from AWS api and a dynamic group is created for accessing the Windows server with
WinRM HTTP and NTLM password authentication as Administrator.

## Setuping Windows machine

1. After server is accessible, Root and Intermediate CA certificates are copied to the server and imported to certificate store
2. Certificate request template is copied to the server & certificate request is made by using that
3. Certificate request is signed with the CA and signed certificate is imported to the server
4. WinRM HTTPS interface is enabled with uploaded certificate
5. Client certificate is created for user named winrm-admin
6. winrm-admin user is created to the server & client certificate is bound for that user
7. A dynamic group called windows-tls is created, it will use WinRM HTTPS interface, certificate authentication and winrm-admin user

## Finalizing installation
1. IIS server is installed
2. A custom index.html is copied to the server

# Further readings / references
* Ansible Windows support documentation: http://docs.ansible.com/ansible/latest/intro_windows.html
* Ansible Windows modules: http://docs.ansible.com/ansible/latest/list_of_windows_modules.html
* OpenSSL certificate authority: https://jamielinux.com/docs/openssl-certificate-authority/introduction.html
* Powershell Remoting security considerations: https://docs.microsoft.com/en-us/powershell/scripting/setup/winrmsecurity?view=powershell-6
