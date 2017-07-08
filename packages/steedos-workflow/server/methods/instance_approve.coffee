Meteor.methods
	set_approve_have_read: (instanceId, traceId, approveId)->
		instance = db.instances.findOne({_id: instanceId, "traces._id": traceId}, {fields: {"traces.$": 1}})

		if instance?.traces?.length > 0
			trace = instance.traces[0]

			trace.approves.forEach (approve)->
				if approve._id == approveId
					approve.is_read = true;
					approve.read_date = new Date();

			db.instances.update({
				_id: instanceId,
				"traces._id": traceId
			}, {
				$set: {"traces.$.approves": trace.approves}
			});
			return true;

	change_approve_info: (instanceId, traceId, approveId, description, finish_date)->
		check(instanceId, String)
		check(traceId, String)
		check(approveId, String)
		check(description, String)
		check(finish_date, Date)

		instance = db.instances.findOne({_id: instanceId, "traces._id": traceId}, {fields: {"traces.$": 1}})

		if instance?.traces?.length > 0
			trace = instance.traces[0]

			trace.approves.forEach (approve)->
				if approve._id == approveId
					approve.description = description
					approve.finish_date = finish_date
					approve.cost_time = approve.finish_date - approve.start_date

			db.instances.update({
				_id: instanceId,
				"traces._id": traceId
			}, {
				$set: {"traces.$.approves": trace.approves}
			})
			return true

	update_approve_sign: (instanceId, traceId, approveId, sign_field_code, description, sign_type, lastSignApprove)->
		check(instanceId, String)
		check(traceId, String)
		check(approveId, String)
		check(sign_field_code, String)
		check(description, String)

		if lastSignApprove

			instance = db.instances.findOne({_id: instanceId, "traces._id": lastSignApprove.trace}, {fields: {"traces.$": 1}})

			lastTrace = _.find instance?.traces, (t)->
				return t._id = lastSignApprove.trace

			if lastTrace
				lastTrace?.approves.forEach (a)->
					if a._id == lastSignApprove._id
						if sign_type == "update"
							a.sign_show = false
#							else
#								a.sign_show = true

				db.instances.update({
					_id: instanceId,
					"traces._id": lastTrace._id
				}, {
					$set: {"traces.$.approves": lastTrace.approves}
				})

		instance = db.instances.findOne({_id: instanceId, "traces._id": traceId}, {fields: {"traces.$": 1}})


		if instance?.traces?.length > 0

			trace = instance.traces[0]

			trace.approves.forEach (approve)->
				if approve._id == approveId
					approve.sign_field_code = sign_field_code
					approve.description = description
					approve.sign_show = true

			db.instances.update({
				_id: instanceId,
				"traces._id": traceId
			}, {
				$set: {"traces.$.approves": trace.approves}
			})
			return true