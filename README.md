# DevSecOps

Follow these steps to set up a monitoring system using AWS services:

1. **AWS Account**

   - Ensure you have administrative access.

2. **Enable GuardDuty**

   - Turn on GuardDuty to monitor your AWS environment for security threats.

3. **SNS (Simple Notification Service)**

   - **Create a topic:**
     - Navigate to the SNS dashboard and create a new topic.
   - **Create a subscription:**
     - Subscribe to the topic. Here, you can add any endpoint you want. For simplicity, I’ve only added my phone number.

4. **CloudWatch Rule**

   - Set up a CloudWatch rule to respond to specific AWS events.

5. **Create a CloudWatch Alarm**

   - Use a custom rule that watches for any GuardDuty event.
   - Configure the alarm to send notifications to the SNS topic created in step 3.
   - **Note**: This step requires the creation of an EventBridge rule.

6. **GuardDuty**

   - Go to the GuardDuty dashboard and generate a few sample alerts to test the system.

7. **Verification**
   - Check your email or phone to verify the success of the setup.
