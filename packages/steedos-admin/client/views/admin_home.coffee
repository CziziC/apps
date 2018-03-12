Template.admin_home.helpers Admin.adminSidebarHelpers

Template.admin_home.helpers
	adminTitle: ->
		if Steedos.isMobile()
			return t "tabbar_admin"
		else
			return t "Steedos Admin"

Template.admin_home.events
	'click .weui-cell-help':() ->
		Steedos.showHelp();

Template.admin_home.onRendered ->
	if Steedos.isMobile() and Steedos.isSpaceAdmin()
		if !Template.admin_home.copyInfoClipboard
			copyInfoClipboard = new Clipboard('.weui-cell-space_invitation', text: () ->
				url = "steedos/sign-up?spaceId=#{Steedos.spaceId()}" 
				url = Meteor.absoluteUrl(url)
				return url
			)
			
			Template.admin_home.copyInfoClipboard = copyInfoClipboard

			copyInfoClipboard.on 'success', (e) ->
				e.clearSelection()
				toastr.success t("steedos_contacts_invitation_copy_success")
			copyInfoClipboard.on 'error', (e) ->
				alert(JSON.stringify(e))
				toastr.error t("steedos_contacts_copy_failed")

Template.admin_home.onDestroyed ->
	Template.admin_home.copyInfoClipboard.destroy()