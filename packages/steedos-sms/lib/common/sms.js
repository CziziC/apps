SMSQueue.collection = new Mongo.Collection('_sms_queue');

var _validateDocument = function(sms) {

	check(sms, {
		sms: Object,
		sent: Match.Optional(Boolean),
		sending: Match.Optional(Match.Integer),
		createdAt: Date,
		createdBy: Match.OneOf(String, null)
	});

};

SMSQueue.send = function(options) {
	var currentUser = Meteor.isClient && Meteor.userId && Meteor.userId() || Meteor.isServer && (options.createdBy || '<SERVER>') || null
	var sms = _.extend({
		createdAt: new Date(),
		createdBy: currentUser
	});

	if (Match.test(options, Object)) {
		sms.sms = _.pick(options, 'Format', 'Action', 'ParamString', 'RecNum', 'SignName', 'TemplateCode');
	}

	sms.sent = false;
	sms.sending = 0;

	_validateDocument(sms);

	return SMSQueue.collection.insert(sms);
};