Template.instanceSignText.helpers InstanceSignText.helpers

Template.instanceSignText.events
	'click .instance-sign-text-btn': (event, template)->
		form_version = WorkflowManager.getInstanceFormVersion();
		fields = form_version?.fields

		modal_title = fields?.findPropertyByPK("code", template.data.name)?.name || template.data.name

		Modal.show("instanceSignModal", {modal_title: modal_title, sign_field_code: template.data.name})
		
Template.instanceSignText.onDestroyed ->
	Session.set("instance_my_approve_description", null)