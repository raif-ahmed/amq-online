package com.redhat.demo.rahmed;

import java.util.HashMap;
import java.util.Map;

import org.apache.camel.builder.RouteBuilder;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "address")
public class AMQPDemo extends RouteBuilder {
	private String topicName;
	private String subcsribtionName;
	private String queueName;
	
	private Boolean topicDemoEnabled=false;
	private Boolean queueDemoEnabled=true;

	
	public boolean isTopicDemoEnabled() {
		return topicDemoEnabled;
	}
	public boolean isQueueDemoEnabled() {
		return queueDemoEnabled;
	}
	public void setEnableTopicDemo(boolean enableTopicDemo) {
		this.topicDemoEnabled = enableTopicDemo;
	}
	public void setEnableQueueDemo(boolean enableQueueDemo) {
		this.queueDemoEnabled = enableQueueDemo;
	}

	public String getTopicName() {
		return topicName;
	}

	public void setTopicName(String topicName) {
		this.topicName = topicName;
	}

	public String getSubcsribtionName() {
		return subcsribtionName;
	}

	public void setSubcsribtionName(String subcsribtionName) {
		this.subcsribtionName = subcsribtionName;
	}

	public String getQueueName() {
		return queueName;
	}

	public void setQueueName(String queueName) {
		this.queueName = queueName;
	}

	public Map<String, Object> processDummyJMSMessage() {

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("ID", "1");
		map.put("MESSAGE_ATTRIBUTE_1", "asdsad");
		map.put("MESSAGE_ATTRIBUTE_2", "asdasddsasad");
		//message.setLongProperty(ScheduledMessage.AMQ_SCHEDULED_DELAY, time);

		return map;
	}

	@Override
	public void configure() {

		if(isTopicDemoEnabled())
		{
			from("timer:demo?period=3000")
				.routeId("route-timer-topic-producer").streamCaching().tracing()
					.setBody(simple("Hello World !!"))
					.log("Sending Message ${body} to Topic amqp:topic:" + getTopicName())
					.to("amqp:topic:" + getTopicName())
			.end();
	
			from("amqp:queue:" + getSubcsribtionName())
				.routeId("route-from-topic-subscription").streamCaching().tracing()
					.log("Recieved Message ${body} from Queue amqp:queue:" + getSubcsribtionName())
			.end();
		}

		if(isQueueDemoEnabled())
		{
			from("timer:demo?period=3000")
				.routeId("route-timer-queue-producer").streamCaching().tracing()
					.setBody(simple("Hello World !!"))
					.log("Sending Message ${body} to Queue amqp:queue:" + getQueueName())
					.to("amqp:queue:" + getQueueName())
			.end();
				
			from("amqp:queue:" + getQueueName())
				.routeId("route-from-queue-consumer").streamCaching().tracing()
					.log("Recieved Message ${body} from Queue amqp:queue:" + getQueueName())
			.end();
				
		}

	}
}
