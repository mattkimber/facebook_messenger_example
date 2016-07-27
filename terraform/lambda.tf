resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = <<EOF
{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
}
    EOF
}


resource "aws_iam_policy" "lambda_policy" {
    name = "lambda_policy"
    description = "Policy for Lambda functions which allows logging"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
}
    EOF
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
    name = "lambda_policy_attachment"
    roles = ["${aws_iam_role.iam_for_lambda.name}"]
    policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_lambda_function" "verify_webhook" {
    function_name = "verify_webhook"
    filename = "files/code.zip"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "verify.handler"
    runtime = "nodejs4.3"
    
    # This is necessary if you want Terraform/AWS to identify that 
    # the code has been updated
    source_code_hash = "${base64sha256(file("files/code.zip"))}"
}

resource "aws_lambda_permission" "allow_api_gateway_verify" {
    statement_id = "AllowExecutionFromApiGateway"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.verify_webhook.arn}"
    principal = "apigateway.amazonaws.com"
}


resource "aws_lambda_function" "process_webhook" {
    function_name = "process_webhook"
    filename = "files/code.zip"
    role = "${aws_iam_role.iam_for_lambda.arn}"    
    handler = "message_processing.handler"
    runtime = "nodejs4.3"
    timeout = 30
    
    # This is necessary if you want Terraform/AWS to identify that 
    # the code has been updated
    source_code_hash = "${base64sha256(file("files/code.zip"))}"
}

resource "aws_lambda_permission" "allow_api_gateway_process" {
    statement_id = "AllowExecutionFromApiGateway"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.process_webhook.arn}"
    principal = "apigateway.amazonaws.com"
}