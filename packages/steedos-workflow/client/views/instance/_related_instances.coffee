RelatedInstances.helpers =
	showRelatedInstaces: ->
		if Meteor.isClient
			ins = WorkflowManager.getInstance();
		else
			ins = Template.instance().view.template.steedosData.instance
		if ins.related_instances && _.isArray(ins.related_instances)
			return true
		else
			return false

	related_instaces: ->
		if Meteor.isClient
			ins = WorkflowManager.getInstance();
		else
			ins = Template.instance().view.template.steedosData.instance
		if ins.related_instances && _.isArray(ins.related_instances)
			return db.instances.find({_id: {$in: ins.related_instances}}, {fields: {space: 1, name: 1}}).fetch()

	related_instace_url: (ins) ->

		absolute = false

		if Meteor.isServer
			absolute = Template.instance().view.template.steedosData.absolute
		if absolute
			return Meteor.absoluteUrl("workflow/space/"+ins.space+"/view/readonly/" + ins._id)
		else
			return Steedos.absoluteUrl("workflow/space/"+ins.space+"/view/readonly/" + ins._id)

	_t: (key)->
		if Meteor.isClient
			return TAPi18n.__(key)
		else
			locale = Template.instance().view.template.steedosData.locale
			return TAPi18n.__(key, {}, locale)