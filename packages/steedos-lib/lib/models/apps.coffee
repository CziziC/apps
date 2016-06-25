db.apps = new Meteor.Collection('apps')

db.apps._simpleSchema = new SimpleSchema
	space: 
		type: String,
		optional: true,
		autoform: 
			type: "hidden",
			defaultValue: ->
				return Session.get("spaceId");
	name:
		type: String
		max: 200
	url:
		type: String
		max: 200
	icon:
		type: String
		max: 200
		autoform:
			defaultValue: "ion-ios-keypad-outline"
		optional: true,
	space_sort:
		type: Number
	secret:
		type: String
		max: 200
		optional: true,
	internal:
		type: Boolean
		optional: true,
		autoform: 
			omit: true
	mobile:
		type: Boolean
		optional: true,
	sort:
		type: Number
		optional: true,
		defaultValue: 9000
		autoform: 
			omit: true

if Meteor.isClient
	db.apps._simpleSchema.i18n("apps")

db.apps.attachSchema db.apps._simpleSchema;
