Admin.adminSidebarHelpers =

	spaceId: ->
		if Session.get("spaceId")
			return Session.get("spaceId")
		else
			return localStorage.getItem("spaceId:" + Meteor.userId())

	boxName: ->
		if Session.get("box")
			return t(Session.get("box"))

	boxActive: (box)->
		if box == Session.get("box")
			return "active"

	menuClass: (urlTag)->
		path = Session.get("router-path")
		if path?.startsWith "/" + urlTag or path?.startsWith "/steedos/" + urlTag
			return "active"

	isWorkflowAdmin: ()->
		if Steedos.isSpaceAdmin() then Steedos.getSpaceAppById("workflow") else false

	isPortalAdmin: ()->
		return Steedos.getSpaceAppByUrl("/portal/home")

	sidebarMenu: ()->
		return Admin.menuTemplate.getSidebarMenuTemplate()

	homeMenu: ()->
		return Admin.menuTemplate.getHomeTemplate()


Template.adminSidebar.helpers Admin.adminSidebarHelpers

Template.adminSidebar.events

	'click .main-header .logo': (event) ->
		Modal.show "app_list_box_modal"

	'click .fix-collection-helper a': (event) ->
		# 因部分admin列表界面在进入路由的时候会出现控制台报错：data[a[i]] is not a function
		# 且只有从admin列表界面进入到admin列表界面时才可能会报上面的错误信息
		# 所以这里加上fix-collection-helper样式类内的a链接先额外跳转到一个非admin列表界面，然后再让其自动跳转到href界面，这样可以避开错误信息
		FlowRouter.go("/admin/home")

	'click .steedos-help': (event) ->
		Steedos.showHelp();




Admin.menuTemplate = 

	getSidebarMenuTemplate: ()->
		reTemplates = db.admin_menus.find({parent:null}, {sort: {sort: 1}}).map (rootMenu, rootIndex) ->
			unless Admin.menuTemplate.checkRoles(rootMenu)
				return ""
			children = db.admin_menus.find({parent:rootMenu._id}, {sort: {sort: 1}})
			if children.count()
				items = children.map (menu, index) ->
					unless Admin.menuTemplate.checkRoles(menu)
						return ""
					# 二级菜单才有url及onclick函数
					if typeof menu.onclick == "function"
						$("body").on "click", ".admin-menu-#{menu._id}", ->
							menu.onclick()

					if menu.target == "_blank"
						targetStr = "target=\"_blank\""

					return """
						<li><a class ="admin-menu-#{menu._id}" href="#{menu.url}" #{targetStr}><i class="#{menu.icon}"></i><span>#{t(menu.title)}</span></a></li>
					"""
				return """
					<li class="treeview">
						<a href="javascript:void(0)">
							<i class="#{rootMenu.icon}"></i>
							<span>#{t(rootMenu.title)}</span>
							<span class="pull-right-container">
								<i class="fa fa-angle-left pull-right"></i>
							</span>
						</a>
						<ul class="treeview-menu">
							#{items.join("")}
						</ul>
					</li>
				"""
			else
				if typeof rootMenu.onclick == "function"
					$("body").on "click", ".admin-menu-#{rootMenu._id}", ->
						rootMenu.onclick()

				unless Admin.menuTemplate.checkRoles(rootMenu)
						return ""
				if rootMenu.target == "_blank"
					targetStr = "target=\"_blank\""

				return """
					<li><a class="admin-menu-#{rootMenu._id}" href="#{rootMenu.url}" #{targetStr}><i class="#{rootMenu.icon}"></i><span>#{t(rootMenu.title)}</span></a></li>
				"""
		return reTemplates.join("")

	getHomeTemplate: ()->
		reTemplates = db.admin_menus.find({parent:null}, {sort: {sort: 1}}).map (rootMenu, rootIndex) ->
			unless Admin.menuTemplate.checkRoles(rootMenu)
				return ""
			children = db.admin_menus.find({parent:rootMenu._id}, {sort: {sort: 1}})
			if children.count()
				items = children.map (menu, index) ->
					unless Admin.menuTemplate.checkRoles(menu)
						return ""
					return """
						<div class="col-xs-6 col-sm-4 col-md-3 col-lg-2">
							<a href="#{menu.url}" class="admin-grid-item btn btn-block admin-menu-#{menu._id}">
								<div class="admin-grid-icon">
									<i class="#{menu.icon}"></i>
								</div>
								<div class="admin-grid-label">
									#{t(menu.title)}
								</div>
							</a>
						</div>
					"""
				return """
					<div class="row admin-grids">
						#{items.join("")}
					</div>
				"""
			else
				unless Admin.menuTemplate.checkRoles(rootMenu)
						return ""
				if rootMenu.target == "_blank"
					targetStr = "target=\"_blank\""
				return """
					<div class="row admin-grids">
						<div class="col-xs-6 col-sm-4 col-md-3 col-lg-2">
							<a href="#{rootMenu.url}" class="admin-grid-item btn btn-block admin-rootMenu-#{rootMenu._id}" #{targetStr}>
								<div class="admin-grid-icon">
									<i class="#{rootMenu.icon}"></i>
								</div>
								<div class="admin-grid-label">
									#{t(rootMenu.title)}
								</div>
							</a>
						</div>
					</div>
				"""
		return reTemplates.join("")

	checkRoles: (menu)->
		unless menu
			return false
		isChecked = true
		if menu.app
			# 只有第一层menu需要判断是否有APP权限
			isChecked = !!Steedos.getSpaceAppById(menu.app)

		if menu.app and menu.paid
			unless Steedos.isPaidSpace()
				isChecked = false

		if isChecked and menu.roles?.length
			roles = menu.roles
			for i in [1..roles.length]
				role = roles[i-1]
				switch role
					when "space_admin"
						unless Steedos.isSpaceAdmin()
							isChecked = false
					when "space_owner"
						unless Steedos.isSpaceOwner()
							isChecked = false
					when "cloud_admin"
						unless Steedos.isCloudAdmin()
							isChecked = false
				unless isChecked
					break 
			return isChecked
		return isChecked
