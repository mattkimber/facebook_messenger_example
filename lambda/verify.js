exports.handler = (event, context, callback) => {
    if (event.params.querystring["hub.mode"] === "subscribe" &&
        event.params.querystring["hub.verify_token"] === event["stage-variables"].facebook_verify_token) {
        callback(null, event.params.querystring["hub.challenge"])
    } else {
		console.log("Validation attempt failed.")
        callback("Failed validation. Make sure the validation tokens match.", null)
    }      
}