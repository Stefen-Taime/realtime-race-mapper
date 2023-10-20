[

![Stefentaime](https://miro.medium.com/v2/resize:fill:88:88/1*ZvANyDda9Ual0g4Cq0RIug.jpeg)



](https://medium.com/@stefentaime_10958?source=post_page-----4e4f867db763--------------------------------)

![](https://miro.medium.com/v2/resize:fit:1250/1*Hiaru2Y0tpvz7JQn7hwY2A.png)

Introduction:

One such inspiration for our project came from Saubury’s race-mapper, which can be found on [GitHub](https://github.com/saubury/race-mapper/tree/master). Saubury’s original implementation provided a solid foundation, utilizing tools like Elastic, Kibana, and MQTT. However, as with all technological endeavors, there’s always room for innovation and adaptation. With a desire to elevate the project to the cloud and integrate a different set of tools, I embarked on a journey to reimagine the race-mapper. In this rendition, Elastic and Kibana have been replaced with the powerful Splunk, MQTT has been swapped out for ActiveMQ, and instead of the traditional Kafka, we’ve integrated Confluent Cloud.

![](https://miro.medium.com/v2/resize:fit:1250/1*ns8c1anZYX02_2A2Goyq8A.gif)

In today’s digital age, real-time data processing has become paramount, especially in dynamic scenarios like a running race. Imagine a race where every stride, every heartbeat, and every second counts. Now, imagine harnessing the power of that data in real-time, transforming it, and visualizing it in a comprehensive dashboard.

Let’s take a glimpse at a sample data point:

```
{  "who": "alice",  "timeepoc": 1558212482,  "lat": -33.87052833,  "lon": 151.21292,  "alt": 31.0,  "batt": 0,  "speed": 10.85}
```

This data represents a runner named Alice, her location coordinates, altitude, battery status, and speed at a specific timestamp.

![](https://miro.medium.com/v2/resize:fit:1250/1*EfEStRaztU_ll-Pvq64TRQ.png)

Such granular data points are crucial in understanding and analyzing the performance of each participant.

This article delves deep into the creation of a robust streaming data pipeline tailored for a running race. We’ll journey from deploying infrastructure with Terraform on GCP, navigating through the intricacies of ActiveMQ with Docker, integrating with Kafka using Confluent Cloud, performing data transformations with ksqlDB, and finally visualizing our results in a real-time Splunk dashboard. Whether you’re a data enthusiast, a sports aficionado, or someone curious about the confluence of technology and athleticism, this article promises a blend of tech insights and practical implementations. Strap on your running shoes and let’s dive in! 🚀👟📈

## Data Processing and Transformation with ksqlDB:

Once the data is received in ActiveMQ, it’s not yet ready for direct visualization. It requires a series of transformations to make it actionable. This is where Kafka and ksqlDB come into play.

![](https://miro.medium.com/v2/resize:fit:1250/1*5KhHITxq1FEkdyZkSHjUSg.png)

Using a Kafka connector, the data from ActiveMQ is sent to a Kafka topic named ‘race-mapper-confluent-topic’. Once inside this topic, we employ ksqlDB, a stream processing engine for Kafka, to execute a series of scripts that transform and prepare our data:

```
-- Create a stream to read Base64-encoded dataCREATE STREAM ENCODED_STREAM (BYTES VARCHAR)  WITH (KAFKA_TOPIC='race-mapper-confluent-topic', VALUE_FORMAT='JSON');-- Create a decoded streamCREATE STREAM DECODED_STREAM AS  SELECT FROM_BYTES(TO_BYTES(BYTES, 'BASE64'), 'UTF8') AS DECODED_PAYLOAD  FROM ENCODED_STREAM;-- Extract JSON payload fieldsCREATE STREAM DATA_STREAMWITH (KAFKA_TOPIC='DATA_STREAM', VALUE_FORMAT='JSON') AS  SELECT    EXTRACTJSONFIELD(DECODED_PAYLOAD, '$.who') AS WHO,    EXTRACTJSONFIELD(DECODED_PAYLOAD, '$.timeepoc') AS TIMEEPOC,    CAST(EXTRACTJSONFIELD(DECODED_PAYLOAD, '$.lat') AS DOUBLE) AS LAT, -- Extraction modifiée    CAST(EXTRACTJSONFIELD(DECODED_PAYLOAD, '$.lon') AS DOUBLE) AS LON, -- Extraction modifiée    CAST(EXTRACTJSONFIELD(DECODED_PAYLOAD, '$.alt') AS DOUBLE) AS ALT,    EXTRACTJSONFIELD(DECODED_PAYLOAD, '$.batt') AS BATT,    EXTRACTJSONFIELD(DECODED_PAYLOAD, '$.speed') AS SPEED  FROM DECODED_STREAM;-- Create a stream with a specified schema based on the previously generated topiccreate stream data_demo_stream  (who varchar, batt INTEGER, lon DOUBLE, lat DOUBLE, timeepoc BIGINT, alt DOUBLE, speed DOUBLE) with (kafka_topic = 'DATA_STREAM', value_format='JSON');-- Create a table to calculate data statisticsCREATE table runner_status with (value_format='JSON') AS select who,  min(speed) as min_speed,  max(speed) as max_speed,  min(GEO_DISTANCE(CAST(lat AS DECIMAL(9,6)), CAST(lon AS DECIMAL(9,6)), -33.87014, 151.211945, 'km')) as dist_to_finish,  count(*) as num_events from data_demo_stream WINDOW TUMBLING (size 5 minute) group by who;-- Create a stream to standardize location dataCREATE STREAM runner_location WITH (value_format='JSON') ASSELECT who,       timeepoc AS event_time,       CONCAT(CAST(lat AS STRING), ',', CAST(lon AS STRING)) AS LOCATION,       alt,       batt,       speedFROM data_demo_stream;
```

These scripts perform several tasks, including decoding the data, extracting relevant fields from the JSON payload, creating streams with specified schemas, and even generating statistics on the data.

![](https://miro.medium.com/v2/resize:fit:1250/1*O_VdPIOKYnfEHNHMtLzhpw.png)

Once these transformations are done, the data is ready to be consumed again. Using another Kafka Connect connector, it’s sent to Splunk. Within Splunk, index is created to store this transformed data, and a real-time dashboard is set up to visualize and analyze the runners’ performances live.

This combination of ActiveMQ, Kafka, ksqlDB, and Splunk provides a robust and scalable solution for processing and visualizing real-time data, ensuring every pivotal moment of a race is captured, analyzed, and presented meaningfully.

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
