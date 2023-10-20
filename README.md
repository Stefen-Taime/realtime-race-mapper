Introduction:
​
One such inspiration for our project came from Saubury’s race-mapper, which can be found on [GitHub](https://github.com/saubury/race-mapper/tree/master).
Saubury’s original implementation provided a solid foundation, utilizing tools like Elastic, Kibana, and MQTT. However, as with all technological endeavors, there’s always room for innovation and adaptation. With a desire to elevate the project to the cloud and integrate a different set of tools, I embarked on a journey to reimagine the race-mapper. In this rendition, Elastic and Kibana have been replaced with the powerful Splunk, MQTT has been swapped out for ActiveMQ, and instead of the traditional Kafka, we’ve integrated Confluent Cloud.
​
![](https://cdn-images-1.medium.com/max/3764/1*ns8c1anZYX02_2A2Goyq8A.gif)
​

Getting Started with the Project:

Embarking on this journey to set up a real-time race mapper requires a series of steps. Here’s a step-by-step guide to get you started:

1.  Clone the Repository: Begin by cloning the main repository:

-   `git clone [https://github.com/Stefen-Taime/realtime-race-mapper.git](https://github.com/Stefen-Taime/realtime-race-mapper.git)`

Terraform Setup: Navigate to the terraform directory and initialize Terraform:

-   `cd terraform`
-   `terraform init`
-   Apply the Terraform configurations:
-   `terraform apply`Review the plan:
-   `terraform plan`

Connect to the GCP Instance: Once deployed, connect to the instance using the following command:

-   `gcloud compute ssh ubuntu@activemq-instance --zone=us-central1-a --project [YOUR_PROJECT_ID]`

Environment Setup: After connecting, create and activate a virtual environment:

-   `source myenv/bin/activate`

Clone the Repository Again: Clone the repository once more within the instance:

-   bashCopy code
-   `git clone [https://github.com/Stefen-Taime/realtime-race-mapper.git](https://github.com/Stefen-Taime/realtime-race-mapper.git)`

ActiveMQ Setup: Navigate to the ActiveMQ directory, grant permissions to the script, and execute it:

-   `cd realtime-race-mapper/activemq`
-   `chmod +x activemq.sh`
-   `./activemq.sh`

Confluent Cloud Configuration:

-   Head over to Confluent Cloud.
-   First, create a topic named `race-mapper-confluent-topic`.
-   Then, set up a source connector for ActiveMQ and a sink connector for Splunk. You can refer to the `connectors` directory for guidance.

Execute ksqlDB Queries: Run the series of queries located in the `ksqldb` directory. Once completed, you can verify the created streams, tables, and topics.

Splunk Configuration:

-   Navigate to Splunk and create a new index.
-   Under settings, add a data input of type “HTTP Event Collector”.
-   Once everything is set up, you can start building your dashboard using the queries found in the `splunk` directory.

Clean Up: Don’t forget to destroy the GCP instance once you’re done to avoid incurring unnecessary costs:

```
terraform destroy
```

With these steps, you’ll have a fully functional real-time race mapper up and running. Enjoy the insights and visualizations!
