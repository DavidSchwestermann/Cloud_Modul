1 folder which contains a file ‘rds.tf’, which will create multiple resources like Configuring 
to AWS, Creating Security Group, Creating a DB Instance, Creating a local file so that, all the 
credentials I want can be fetched and copied easily.


‘main.tf’ file which contains a module which will be called, when we run this file. In this module, 
I have passed some variables to the rds.tf file.


‘variable.tf’ file contains 3 variables, which contains the value of my name, username, password 
(of this username) of the Database.


Aneleitung: https://akhileshjain9221.medium.com/creating-an-infrastructure-by-integrating-terraform-and-ansible-on-aws-596afd444a9c
