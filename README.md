# GBFSApp

 This task is for : https://github.com/umob-app/hiring-assignment/blob/main/devops-engineering.md

 ## App Idea

 I choose 3 providers : 
``` py
providers = [
    {"name": "Careem BIKE", "url": "https://dubai.publicbikesystem.net/customer/gbfs/v2/gbfs.json"},
    {"name": "Bike Nordelta", "url": "https://nordelta.publicbikesystem.net/ube/gbfs/v1/"},
    {"name": "Ecobici", "url": "https://buenosaires.publicbikesystem.net/ube/gbfs/v1/"}
]
```
- you can add more .
- The script will create the db table if it doesn't exist and only have simple data like :
```py
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS bike_stats (
                    id SERIAL PRIMARY KEY,
                    provider VARCHAR(50),
                    station_id VARCHAR(50),
                    bike_count INT,
                    timestamp TIMESTAMP
                );
                """
            )
```
  You can add more data from the files, But this is just for POC.
- The Script will search for the `station_status` url so It can monitor the available bikes and other data.
- The script uses `Threading` so each link will be monitored in it's own thread and data is saved in postgresql db .
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
![image](https://github.com/user-attachments/assets/972f855d-06b2-4539-a9cf-7d0606143dec)

- Enter `username : admin` and `password: admin` . then enter your new password.
![image](https://github.com/user-attachments/assets/17e5ec27-d7a8-4570-90bb-5a6f073fea98)

- in the side bar add new `Datasource` and enter in the search `postgres` then click on it.
  ![image](https://github.com/user-attachments/assets/6e16eeec-d141-4b5a-980d-20a8d6c83a8b)
  ![image](https://github.com/user-attachments/assets/56472b86-e0bd-48e2-b03d-5d11512f84bc)

- Enter data as follows:
       - in the `Connection` section :
          = `Host URL *` : `postgres:5432`
          = `Database name *` : `gbfs_db`
       - in the `Authentication` section:
          = `Username *` : `gbfs_user`
          = `Password *` : `gbfs_password`
          = `TLS/SSL Mode` : choose from the drop-down menue -> `disable`
![image](https://github.com/user-attachments/assets/d0a83a0f-766f-4811-abd2-3a48b6437051)

- Then click on `Import a dashboard`and choose the dashboard json file from our repo : https://github.com/HalaEzzat/GBFSApp/blob/main/Bike%20Stats%20Dashboard.json
![image](https://github.com/user-attachments/assets/58b10bad-7ef7-4ea7-8fba-9f73948a993b)
- This will automatically create the Dasboard which looks like this:
![imported dashboard](https://github.com/user-attachments/assets/7fa6021c-450e-45a9-afd5-a6cf38394817)
- To Destroy all resources just rerun the `destroy` job manually.

## Other Approaches [not so free-tier]:

- create a lambda function to parse your json file and monitore changes.
- create dynamodb to host your data
- create ec2 to host Grafana or you can also create it as ECS Task then add DynamoDB as a Datasource

This was my first approach only to findout that to use DynamoDB as a Datasource in grafana you'll need an enterprise license .
I even found that in Grafana you can add json as a data source then create your dashboard based on it . but I think we still need database for historical data .
I think real life approach we will use a historical database or big data for better data analysis and metrics and ofcourse I would create a more secured infrastructure.
I also tried another approach : using `ELK Stack` in terraform .

There's multiple good options but I decided to go with the easist one just for poc . I also didn't apply much security in my solution for easier access and demo.
