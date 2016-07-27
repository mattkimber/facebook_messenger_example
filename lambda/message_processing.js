const request = require('request')

var ACCESS_TOKEN

exports.handler = (event, context, callback) => {
    ACCESS_TOKEN = event["stage-variables"].facebook_page_token
    
    if(event["body-json"].object == "page") {
        var entries = event["body-json"].entry
        entries.forEach((entry) => { 
            entry.messaging.forEach(processMessage)
        })
    }
    
    callback(null, "")
}

var processMessage = (message) => {
    var messageText = message.message.text
    
    if(messageText) {
		sendMessage(message.sender.id, "You said: " + messageText)
    }
}

var sendMessage = (recipient_id, message) => {
    var data = {
        recipient: {
            id: recipient_id
        },
        message: {
            text: message
        }
    }
    
    request({
        uri: 'https://graph.facebook.com/v2.6/me/messages',
        qs: { access_token: ACCESS_TOKEN },
        method: 'POST',
        json: data
    }, 
	function (error, res, body) {
		if (error) {
			console.error("Unable to send message. Response and error follow.")
			console.error(res);
			console.error(error);
		}
  })  
}