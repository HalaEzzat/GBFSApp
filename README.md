# GBFSApp

 This task is for : https://github.com/umob-app/hiring-assignment/blob/main/devops-engineering.md

## Approach

P.S: I only used free tier of everything as this is only a POC of what you can do.

- Created `docker-compose` file for 3 services : Python App, PG-SQL , Grafana.
- Python script parses the JSON files of the providers to get the available bikes per station ID per Provider.
- Python script dumbs the data in a PG-SQL DB so then you can use Datasource : postegres on Grafana.
- Created a simple Grafana Dashboard That shows stats of the available bikes and providers and Exported it.
- Created Terraform that provision EC2 on AWS to host my docker-compose services.
- Created github actions cicd / workflow to manually triiger the pipeline to create and to destroy the resources.

## Steps to run the solution:

- Add AWS credentials and ssh private key [of the ec2 instance] as CI variables on github.
- Create the s3 bucket tht hosts your tfstate file using command :
``` sh
aws s3api create-bucket --bucket hala-elhamahmy --region us-east-1
```
   make sure to change the name of the bucket in terraform files accordingly.
- Trigger the pipeline manually via `Actions` tab in your repo.
- Once it fully runs it will output the ec2 public ip use it as follows: `ip:3000` in your browser .
![terraform run](https://github.com/user-attachments/assets/08d5b4b2-d282-4266-bd9c-d11a7c1c09bf)
- This will allow you to access `Grafana` :
- Enter `username : admin` and `password: admin` . then enter your new password.
- in the side bar add new `Datasource` and enter in the search `postgres` then click on it.
- Enter data as follows
- Then `import Dashboard`and choose the dashboard json file from our repo : https://github.com/HalaEzzat/GBFSApp/blob/main/Bike%20Stats%20Dashboard.json
- This will automatically create the Dasboard which looks like this:
![imported dashboard](https://github.com/user-attachments/assets/7fa6021c-450e-45a9-afd5-a6cf38394817)
- To Destroy all resources just rerun the `destroy` job manually.

## Another Approach:

- 
