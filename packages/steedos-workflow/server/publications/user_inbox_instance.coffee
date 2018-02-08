Meteor.publishComposite "user_inbox_instance", ()->
	unless this.userId
		return this.ready()

	userSpaceIds = db.space_users.find({
		user: this.userId,
		user_accepted: true
	}, {fields: {space: 1}}).fetch().getEach("space");
	query = {space: {$in: userSpaceIds}}

	query.$or = [{inbox_users: this.userId}, {cc_users: this.userId}]

	find: ->
		db.instances.find(query, {
			fields: {
				space: 1,
				applicant_name: 1,
				flow: 1,
				inbox_users: 1,
				cc_users: 1,
				state: 1,
				name: 1,
				modified: 1,
				form: 1
			}, sort: {modified: -1}, skip: 0, limit: 200
		});
	children: [
		{
			find: (instance, post)->
				db.flows.find({_id: instance.flow}, {fields: {name: 1, space: 1}});
		}
	]

Meteor.publish 'my_inbox_instances', ()->
	unless this.userId
		return this.ready()

	self = this;

	console.log "my_inbox_instances"

	userSpaceIds = db.space_users.find({
		user: this.userId,
		user_accepted: true
	}, {fields: {space: 1}}).fetch().getEach("space");

	query = {space: {$in: userSpaceIds}}

	query.$or = [{inbox_users: this.userId}, {cc_users: this.userId}]

	fields = {
		space: 1,
		applicant_name: 1,
		flow: 1,
		inbox_users: 1,
		cc_users: 1,
		state: 1,
		name: 1,
		modified: 1,
		form: 1
	}

	handle = db.instances.find(query, {fields: {_id: 1}, sort: {modified: -1}, skip: 0, limit: 200}).observeChanges {
		added: (id)->
			console.log "added #{id}"
			instance = db.instances.findOne({_id: id}, {fields: fields})
			return if not instance
			instance.is_cc = instance.cc_users?.includes(self.userId) || false
			delete instance.cc_users
			console.log "added instances #{id}"
			self.added("instances", id, instance)
		changed: (id)->
			console.log "changed #{id}"
			instance = db.instances.findOne({_id: id}, {fields: fields})
			return if not instance
			instance.is_cc = instance.cc_users?.includes(self.userId) || false
			delete instance.cc_users
			console.log "changed instances #{id}"
			self.changed("instances", id, instance);
		removed: (id)->
			self.removed("instances", id);
	}

	self.ready();
	self.onStop ()->
		handle.stop()
