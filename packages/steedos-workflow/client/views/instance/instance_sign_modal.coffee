Template.instanceSignModal.helpers
	modal_suggestion: ()->

		history_approve = Template.instance()?.history_approve.get()

		if history_approve && history_approve?.description
			return history_approve.description
		else
			return Session.get("instance_my_approve_description");

Template.instanceSignModal.events
	'click #instance_flow_opinions': (event, template)->
		Session.set('flow_comment', $("#modal_suggestion").val())
		Modal.allowMultiple = true
		Modal.show 'opinion_modal',{parentNode: $("#modal_suggestion")}

	'click #instance_sign_modal_ok': (event, template)->

		myApprove = InstanceManager.getCurrentApprove()

		Meteor.call 'update_approve_sign', myApprove.instance, myApprove.trace, myApprove._id, template.data.sign_field_code, $("#modal_suggestion").val(), $("#sign_type:checked")?.val() || "add", Template.instance()?.history_approve.get() || InstanceSignText.helpers.getLastSignApprove()

		$("#suggestion").val($("#modal_suggestion").val()).trigger("input").focus();

		Modal.allowMultiple = false

		Modal.hide(template)

	'click .instance-sign-opinion-btn': (event, template)->

		val = ($("#modal_suggestion").val() || "") + event.target.text + t("instance_sign_period")

		$("#modal_suggestion").val(val)

	'click .instance-sign-history': (event, template)->
		Modal.allowMultiple = true
		Modal.show 'history_sign_approve', {parent: template}

#	'shown.bs.modal .instance-sign-modal': ()->
#
#		if !Steedos.isMobile()
#			$modal_dialog = $(".instance-sign-modal").find('.modal-dialog');
#
#			m_top = ( $(window).height() - $modal_dialog.height() )/2;
#
#			$modal_dialog.css({'margin': m_top + 'px auto'})

Template.instanceSignModal.onCreated ->
	this.history_approve = new ReactiveVar()