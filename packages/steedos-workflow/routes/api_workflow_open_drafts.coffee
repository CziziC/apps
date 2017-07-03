JsonRoutes.add 'post', '/api/workflow/open/drafts', (req, res, next) ->
	try
		current_user_info = Steedos.getAPILoginUser(req, res)

		if !current_user_info
			JsonRoutes.sendResult res,
				code: 401,
				data:
					"error": "Validate Request -- Missing X-Auth-Token,X-User-Id",
					"success": false
			return;

		space_id = req.headers['x-space-id']

		if not space_id
			throw new Meteor.Error('error', 'need header x_space_id')

		# 校验space是否存在
		uuflowManager.getSpace(space_id)
		# 校验当前登录用户是否是space的管理员
		uuflowManager.isSpaceAdmin(space_id, current_user_info._id)

		hashData = req.body

		console.log "req", req

		if not hashData["flow"]
			throw new Meteor.Error('error', 'flow is null')

		flow_id      = hashData["flow"]
		applicant_id = hashData["applicant"]

		instance_from_client = new Object

		flow = db.flows.findOne(flow_id)
		if not flow
			throw new Meteor.Error('error', 'flow is null')

		if space_id isnt flow.space
			throw new Meteor.Error('error', 'flow is not belong to this space')

		if db.space_users.find({space: space_id, user: current_user_info._id}).count() is 0
			throw new Meteor.Error('error', 'auth_token is not a member of this space')

		instance_from_client["space"] = space_id
		instance_from_client["flow"] = flow_id
		instance_from_client["flow_version"] = flow.current._id

		if applicant_id
			applicant = db.users.findOne(applicant_id)
			if not applicant
				throw new Meteor.Error('error', 'applicant is wrong')

			space_user = uuflowManager.getSpaceUser(space_id, applicant_id)
			if not space_user
				throw new Meteor.Error('error', 'applicant is not a member of this space')

			if space_user.user_accepted isnt true
				throw new Meteor.Error('error', 'applicant is disabled in this space')

			space_user_org_info = uuflowManager.getSpaceUserOrgInfo(space_user)
			instance_from_client["applicant"] = applicant._id
			instance_from_client["applicant_name"] = applicant.name
			instance_from_client["applicant_organization"] =  space_user_org_info["organization"]
			instance_from_client["applicant_organization_fullname"] = space_user_org_info["organization_fullname"]
			instance_from_client["applicant_organization_name"] = space_user_org_info["organization_name"]

		traces = []
		trace = new Object
		approves = []
		approve = new Object
		approve["values"] = hashData["values"]
		approves.push(approve)
		trace["approves"] = approves
		traces.push(trace)
		instance_from_client["traces"] = traces

		instance_from_client["inbox_users"] = [current_user_info._id]

		new_ins_id = uuflowManager.create_instance(instance_from_client, current_user_info)

		new_ins = db.instances.findOne(new_ins_id)

		JsonRoutes.sendResult res,
			code: 200
			data: { status: "success", data: new_ins}
	catch e
		console.error e.stack
		JsonRoutes.sendResult res,
			code: 200
			data: { errors: [{errorMessage: e.message}]}
	
		