# README

## PS-SUPPORTAL
---

This is an application for use within **Firstup, Inc.** The purpose of this application is to streamline support functions and make API and DB driven events easier to perform.

* Ruby Version : `3.1.2p20 [x86_64-linux]`

* System Dependencies : `sqlite3.8+, nginx1, passenger, rails 7.0.4.2, bundler, nodejs, linbuv, curl, git, gcc, postgresql-devel, postgresql-libs, posgresql11`
---
### Configuration `[TODO]` - ***make deploy script***
---


To setup your own workstation, I would suggest [*AWS Linux 2 AMI*](https://aws.amazon.com/amazon-linux-2/?amazon-linux-whats-new.sort-by=item.additionalFields.postDateTime&amazon-linux-whats-new.sort-order=desc). You can setup a machine with free tier for learning purposes. 

Alternatively, Firstup may provide access to the supportal machine. In which case, **you do not need to follow the steps outlined below**. Please ensure you also have AWS SSO access as well to access the Supporal machine. 

---
For this configuration, I am using **CENTOS/AWS Linux 2 AMI** syntax. If you are using a different distro, you will need to change your configuration.

#### **Create User**  
`$adduser {name}`  
`$passwd {name}`  
`$gpasswd -a {name} wheel`  
  
#### **Add Public Key to New Remote User**  
*Generate Private/Public Key Pair*  
`$su -{name}`  
`$mkdir .ssh`  
`$chmod 700 .ssh`  
`$vim .ssh/authorized_keys`  

*Add your Public Key to authorized_keys file!*   

`$chmod 600 .ssh/authorized_keys`  
`$exit`

#### **Configure SSH Daemon**
`$vim /etc/ssh/sshd_config`  
*Uncomment #PermitRootLogin Yes => PermitRootLogin No*  
`$systemctl reload sshd`

#### **Prepare RVM - Install GPG Keys**
[*RVM Documentation*](https://rvm.io/rvm/install#explained)

*Try both gpg and gpg2 if there's an issue! Also try running as sudo!*   

`$gpg2 --keyserver hkp://pgp.mit.edu --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB`

*Alternative Link* : `$gpg2 --keyserver keyserver.ubuntu.com --recv-key 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB`

#### **Install RVM**  
`$curl -sSL https://get.rvm.io | sudo bash -s stable`  
*Add {User} to RVM Group - Must Restart RVM After Each Mod* : `$sudo usermod -a -G rvm `\`whoami\`   

#### **Make Sure RVM Shell Environment Is Set To Secure Path!**  
`$ifsudo grep -q secure_path /etc/sudoers; thensudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh" && echo Environment variable installed; fi`

*When You Are Finished, *relogin to your server* to Activate RVM!*

#### **Install Dependencies**  
`$sudo yum update -y`  
`$sudo yum install curl git gcc postgresql-devel postgresql-libs -y make -y`  
`$sudo amazon-linux-extras install nginx1 posgresql11 -y`  

#### **Customize Hostname**
`$sudo hostnamectl set-hostname {name} *supportal, for the purposes of this tutorial*`

**Amazon Linux 2 AMI Extras Library - Check To See If Any Dependencies Are Missing / Amazon Specific**  
*Skip This Step If Using Different Distro*  
`$amazon-linux-extras list`  
`$sudo amazon-linux extras install {topic}`

*At one point I had to comment out the CA profile reference in my .bashrc profile and install the AMZN specific one from the AMI extras library! If you run into this issue you should try that!*

#### **Install Ruby 3.1.2**
`$rvm install ruby-3.1.2`  
`$rvm --default use ruby-3.1.2`

#### **Install Bundler**
`$gem install bundler --no-documentation`

#### **Install Node.js**
`$sudo yum install -y epel-release / sudo amazon-linux-extras install epel`

#### **Install linbuv**
`$sudo yum install libuv --disableplugin=priorities / sudo yum install -y --enablerepo=epel nodjs npm`

#### **Install Passenger Gem**
`$gem install passenger --no-document`

#### ***Uninstall the OS-install Nginx. The next step will install Passenger/Nginx bundle. Multiple installations of Nginx/Passenger may cause issues!***  
`$sudo yum remove nginx`  
`$sudo rm -rf /etc/nginx`

#### **Run The Passenger/Nginx Module Installer**
`$rvmsudo passenger-install-nginx-module`  

*Possible You Need cURL*: `$rvmsudo yum install libcurl-devel` 

**IMPORTANT:** *If any errors come up, address them before finalizing installation!*  

#### **Validate Installation of Passenger**  
`$rvmsudo passenger-config validate-install`  
`$rvmsudo passenger-memory-stats`

#### **Start Nginx**
`$sudo /opt/nginx/sbin/nginx`

#### **Shutting Down Nginx**
`$sudo kill $(cat /opt/nginx/logs/nginx.pid)`

#### **Restarting Nginx**
`$sudo /opt/nginx/sbin/nginx`

#### **May Require Future SQLite3.8 Update!**
`$wget https://kojipkgs.fedoraproject.org//packages/sqlite/3.8.11/1.fc21/x86_64/sqlite-devel-3.8.11-1.fc21.x86_64.rpm`  
`$wget https://kojipkgs.fedoraproject.org//packages/sqlite/3.8.11/1.fc21/x86_64/sqlite-3.8.11-1.fc21.x86_64.rpm`  
`$sudo yum install sqlite-3.8.11-1.fc21.x86_64.rpm sqlite-devel-3.8.11-1.fc21.x86_64.rpm`  

---
### Useful Documentation
---
**RVM** - [Ruby Version Manager (RVM)](https://rvm.io/)  
**Amazon Linux 2** - [Amazon Linux 2 Overview](https://https://aws.amazon.com/amazon-linux-2/?amazon-linux-whats-new.sort-by=item.additionalFields.postDateTime&amazon-linux-whats-new.sort-order=desc)  
**Phusion Passenger** - [Tutorials](https://www.phusionpassenger.com/docs/tutorials/what_is_passenger/)  
**Nginx** - [Open Source Documentation](https://nginx.org/en/docs/)  
**Ruby on Rails Guides** - [Getting Started with Rails](https://guides.rubyonrails.org/getting_started.html)

---
* Database creation `[TODO]`
---
* Database initialization `[TODO]`
---
* Services `[TODO]` (job queues, cache servers, search engines, etc.)
---
* Deployment instructions `[TODO]`
