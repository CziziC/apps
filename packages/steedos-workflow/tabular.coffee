Steedos.subs["InstanceTabular"] = new SubsManager()

updateTabularTitle = ()->


instancesListTableTabular = (flowId)->
	options = {
		name: "instances",
		collection: db.instances,
		pub: "instance_tabular",
		sub: Steedos.subs["InstanceTabular"],
		onUnload: ()->
			console.log "_tableColumns..."
			Meteor.setTimeout(Template.instance_list._tableColumns, 100)

		drawCallback: (settings)->
			if !Steedos.isMobile() && !Steedos.isPad()
				Meteor.setTimeout(Template.instance_list._tableColumns, 100)
				$(".instance-list").scrollTop(0).ready ->
					$(".instance-list").perfectScrollbar("update")
		createdRow: (row, data, dataIndex) ->
			if Meteor.isClient
				if data._id == FlowRouter.current().params.instanceId
					row.setAttribute("class", "selected")
		columns: [
			{
				data: "_id",
				orderable: false
				render: (val, type, doc) ->
					modifiedString = moment(doc.modified).format('YYYY-MM-DD');
					modifiedFromNow = Steedos.momentReactiveFromNow(doc.modified);
					flow_name = WorkflowManager.getFlow(doc.flow)?.name
					cc_view = "";
					step_current_name_view = "";
					# 当前用户在cc user中，但是不在inbox users时才显示'传阅'文字
					if doc.cc_users?.includes(Meteor.userId()) && !doc.inbox_users?.includes(Meteor.userId()) && Session.get("box") == 'inbox'
						cc_view = "<label class='cc-label'>(" + TAPi18n.__("instance_cc_title") + ")</label> "
						step_current_name_view = "<div class='flow-name'>#{flow_name}<span>(#{doc.step_current_name})</span></div>"
					else
						if Session.get("box") != 'draft' && doc.step_current_name
							step_current_name_view = "<div class='flow-name'>#{flow_name}<span>(#{doc.step_current_name})</span></div>"
						else
							step_current_name_view = "<div class='flow-name'>#{flow_name}</div>"

					unread = ''

					if Session.get("box") == 'inbox' && doc.is_read == false
						unread = '<i class="ion ion-record unread"></i>'

					priorityIcon = ""
					priorityIconClass = ""
					priorityValue = doc.values?.priority
					switch priorityValue
						when "特急"
							priorityIconClass = "danger"
						when "紧急"
							priorityIconClass = "warning"
						when "办文"
							priorityIconClass = "muted"
					if priorityIconClass
						priorityIcon = "<i class='ion ion-flag color-priority color-priority-#{priorityIconClass}'></i>"

					return """
								<div class='instance-read-bar'>#{unread}</div>
								<div class='instance-priority-bar'>#{priorityIcon}</div>
								<div class='instance-name'>#{doc.name}#{cc_view}
									<span>#{doc.applicant_name}</span>
								</div>
								<div class='instance-detail'>#{step_current_name_view}
									<span class='instance-modified' title='#{modifiedString}'>#{modifiedFromNow}</span>
								</div>
							"""
			},
			{
				data: "applicant_organization_name",
				title: t("instances_applicant_organization_name"),
				visible: false,
			},
			{
				data: "name",
				title: t("instances_name"),
				render: (val, type, doc) ->
					cc_view = "";
					step_current_name_view = "";
					# 当前用户在cc user中，但是不在inbox users时才显示'传阅'文字
					if doc.cc_users?.includes(Meteor.userId()) && !doc.inbox_users?.includes(Meteor.userId()) && Session.get("box") == 'inbox'
						cc_view = "<label class='cc-label'>(" + TAPi18n.__("instance_cc_title") + ")</label> "

					unread = ''

					if Session.get("box") == 'inbox' && doc.is_read == false
						unread = '<i class="ion ion-record unread"></i>'

					priorityIconClass = ""
					priorityValue = doc.values?.priority
					switch priorityValue
						when "特急"
							priorityIconClass = "danger"
						when "紧急"
							priorityIconClass = "warning"
						when "办文"
							priorityIconClass = "muted"
					if priorityIconClass
						instanceNamePriorityClass = "color-priority color-priority-#{priorityIconClass}"
					return """
							<div class='instance-read-bar'>#{unread}</div>
							<div class='instance-name #{instanceNamePriorityClass}'>#{doc.name}#{cc_view}</div>
						"""
				visible: false,
				orderable: false
			},
			{
				data: "applicant_name",
				title: t("instances_applicant_name"),
				visible: false,
				orderable: false
			}, {
				data: "submit_date",
				title: t("instances_submit_date"),
				render: (val, type, doc) ->
					if doc.submit_date
						return moment(doc.submit_date).format('YYYY-MM-DD HH:mm');
				,
				visible: false,
				orderable: true
			},
			{
				data: "flow",
				title: t("instances_flow"),
				render: (val, type, doc) ->
					flow_name = WorkflowManager.getFlow(doc.flow)?.name
					return flow_name
				,
				visible: false,
				orderable: false
			}, {
				data: "step_current_name",
				title: t("instances_step_current_name"),
				visible: false,
				orderable: false
			},
			{
				data: "modified",
				title: t("instances_modified"),
				render: (val, type, doc) ->
					return moment(doc.modified).format('YYYY-MM-DD HH:mm');
				,
				visible: false,
				orderable: true
			},
			{
				data: "modified",
				visible: false
			}
		],
		dom: "tp",
		order: [[8, "desc"]],
		extraFields: ["form", "flow", "inbox_users", "outbox_users", "state", "space", "applicant", "form_version",
			"flow_version", "cc_users", "is_read", "step_current_name", "values"],
		lengthChange: false,
		pageLength: 10,
		info: false,
		searching: true,
		responsive:
			details: false
		autoWidth: false,
		changeSelector: (selector, userId) ->
			unless userId
				return {make_a_bad_selector: 1}
			space = selector.space
			unless space
				if selector?.$and?.length > 0
					space = selector.$and.getProperty('space')[0]
			unless space
				return {make_a_bad_selector: 1}
			space_user = db.space_users.findOne({user: userId, space: space}, {fields: {_id: 1}})
			unless space_user
				return {make_a_bad_selector: 1}
			return selector
		pagingType: "numbers"

	}

	if flowId
		key = "instanceFlow" + flowId
		options.name = key

		flow = db.flows.findOne({_id: flowId}, {fields: {form: 1}})
		TabularTables.instances.fields = db.forms.findOne({_id: flow?.form})?.current?.fields

		TabularTables.instances.fields?.forEach (f)->
			if f.type != 'table' && f.is_list_display
				options.columns.push
					data: "modified",
					title: f.name || f.code,
					visible: false,
					orderable: false
					render: (val, type, doc) ->

						values = doc.values || {}

						value = values[f.code]

						switch f.type
							when 'user'
								value = value?.name
							when 'group'
								value = value?.fullname
							when 'date'
								if value
									value = moment(value).format('YYYY-MM-DD')
							when 'dateTime'
								if value
									value = moment(value).format('YYYY-MM-DD HH:mm')
							when 'checkbox'
								if value == true || value == 'true'
									value = TAPi18n.__("form_field_checkbox_yes");
								else
									value = TAPi18n.__("form_field_checkbox_no");

						return value


	return options;

TabularTables.instances = new Tabular.Table instancesListTableTabular()

if Meteor.isClient
	TabularTables.flowInstances = new ReactiveVar()

Tracker.autorun (c) ->
	console.log "TabularTables autorun..."

	if Meteor.isClient && !Steedos.isMobile()
		if Session.get("flowId")
			Meteor.call "newInstancesListTabular", Session.get("flowId"), (error, result) ->
				newInstancesListTabular Session.get("flowId")


newInstancesListTabular = (flowId)->
	flow = db.flows.findOne({_id: flowId}, {fields: {form: 1}})
	fields = db.forms.findOne({_id: flow?.form})?.current?.fields

	if fields?.filterProperty("is_list_display", true)?.length > 0
		key = "instanceFlow" + flowId
		if Meteor.isClient
			TabularTables.flowInstances.set(new Tabular.Table instancesListTableTabular(flowId))
		else
			new Tabular.Table instancesListTableTabular(flowId)
		console.log "new TabularTables ", key

if Meteor.isServer
	Meteor.methods
		newInstancesListTabular: (flowId)->
			newInstancesListTabular(flowId)

