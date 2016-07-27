resource "aws_api_gateway_rest_api" "MessengerApi" {
    name = "FacebookMessengerBot"
    description = "A demo chatbot for Facebook Messenger"
}

resource "aws_api_gateway_resource" "MessengerWebhook" {
    rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
    parent_id = "${aws_api_gateway_rest_api.MessengerApi.root_resource_id}"
    path_part = "webhook"
}

# Integration of the GET request

resource "aws_api_gateway_method" "WebhookGet" {
    rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
    resource_id = "${aws_api_gateway_resource.MessengerWebhook.id}"
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "WebhookGetIntegration" {
    rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
    resource_id = "${aws_api_gateway_resource.MessengerWebhook.id}"
    http_method = "${aws_api_gateway_method.WebhookGet.http_method}"
    integration_http_method = "POST"
    type = "AWS"
    uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.verify_webhook.function_name}/invocations"
    request_templates = {
        "application/json" = "${file("templates/get_inbound_mapping.template")}"
    }
}

# This is nasty and hacky - we have to reverse API Gateway's attempt to produce
# valid JSON from our response, so the Facebook API can correctly interpret the
# response.
resource "aws_api_gateway_integration_response" "WebhookGetIntegrationResponse" {
  depends_on = ["aws_api_gateway_integration.WebhookGetIntegration","aws_api_gateway_method.WebhookGet"]
  rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
  resource_id = "${aws_api_gateway_resource.MessengerWebhook.id}"
  http_method = "${aws_api_gateway_method.WebhookGet.http_method}"
  status_code = "${aws_api_gateway_method_response.Get_200.status_code}"
  response_templates = {
    "application/json" = "${file("templates/get_outbound_mapping.template")}"
  }
}

resource "aws_api_gateway_method_response" "Get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
  resource_id = "${aws_api_gateway_resource.MessengerWebhook.id}"
  http_method = "${aws_api_gateway_method.WebhookGet.http_method}"
  status_code = "200"
}

# Integration of the POST request

resource "aws_api_gateway_method" "WebhookPost" {
    rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
    resource_id = "${aws_api_gateway_resource.MessengerWebhook.id}"
    http_method = "POST"
    authorization = "NONE"    
}

resource "aws_api_gateway_integration" "WebhookPostIntegration" {
    rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
    resource_id = "${aws_api_gateway_resource.MessengerWebhook.id}"
    http_method = "${aws_api_gateway_method.WebhookPost.http_method}"
    integration_http_method = "POST"
    type = "AWS"
    uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.process_webhook.function_name}/invocations"
    request_templates = {
        "application/json" = "${file("templates/get_inbound_mapping.template")}"
    }
}

resource "aws_api_gateway_method_response" "Post_200" {
  rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
  resource_id = "${aws_api_gateway_resource.MessengerWebhook.id}"
  http_method = "${aws_api_gateway_method.WebhookPost.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "WebhookPostIntegrationResponse" {
  depends_on = ["aws_api_gateway_integration.WebhookPostIntegration","aws_api_gateway_method.WebhookPost"]
  rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
  resource_id = "${aws_api_gateway_resource.MessengerWebhook.id}"
  http_method = "${aws_api_gateway_method.WebhookPost.http_method}"
  status_code = "${aws_api_gateway_method_response.Post_200.status_code}"
}


resource "aws_api_gateway_deployment" "MessengerApiDeployment" {
  depends_on = ["aws_api_gateway_integration.WebhookGetIntegration","aws_api_gateway_integration.WebhookPostIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.MessengerApi.id}"
  stage_name = "test"
  stage_description = "Deployment stage for testing"
  variables = {
    "facebook_page_token" = "${var.facebook_page_token}"
    "facebook_verify_token" = "${var.facebook_verify_token}"
	}
}
