Template.history_sign_approve.helpers
	sign_approves: ()->
		ins = WorkflowManager.getInstance()

		sign_approves = TracesManager.getHandlerSignShowApproves(ins, Meteor.userId(), true) || []

		return sign_approves.reverse()


Template.history_sign_approve.events
	'hide.bs.modal #history-sign-approve': (event, template) ->
		Modal.allowMultiple = false;
		return true;

	'click .history-sign-approve tr': (event, template)->
		template.data.parent.history_approve.set(this)
		Modal.hide(template)