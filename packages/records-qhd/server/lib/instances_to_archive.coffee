request = Npm.require('request')

logger = new Logger 'Records_QHD -> InstancesToArchive'

#logger = console
#
#logger.debug = console.log

# spaces: Array 工作区ID
# archive_server: String 档案系统服务
# contract_flows： Array 合同类流程
InstancesToArchive = (spaces, archive_server, contract_flows) ->
	@spaces = spaces
	@archive_server = archive_server
	@contract_flows = contract_flows
	return

#	获取合同类的申请单：正常结束的(不包括取消申请、被驳回的申请单)
InstancesToArchive::getContractInstances = ()->
	return db.instances.find({
		space: {$in: @spaces},
		flow: {$in: @contract_flows},
		is_archived: false,
		is_deleted: false,
		state: "completed",
		"values.record_need": "true",
		$or: [{final_decision: "approved"}, {final_decision: {$exists: false}}, {final_decision: ""}]
	});

InstancesToArchive::getNonContractInstances = ()->
	return db.instances.find({
		space: {$in: @spaces},
		flow: {$nin: @contract_flows},
		is_archived: false,
		is_deleted: false,
		state: "completed",
		"values.record_need": "true",
		$or: [{final_decision: "approved"}, {final_decision: {$exists: false}}, {final_decision: ""}]
	});

InstancesToArchive.success = (instance)->
	logger.info("success, name is #{instance.name}, id is #{instance._id}")
	db.instances.direct.update({_id: instance._id}, {$set: {is_archived: true}})

InstancesToArchive.failed = (instance, error)->
	logger.error("failed, name is #{instance.name}, id is #{instance._id}. error: ")
	logger.error error

#	校验必填
_checkParameter = (formData) ->
	if !formData.FONDSID
		return false
	return true

getFileHistoryName = (fileName, historyName, stuff) ->
	regExp = /\.[^\.]+/

	fName = fileName.replace(regExp, "")

	extensionHistory = regExp.exec(historyName)

	if(extensionHistory)
		fName = fName + "_" + stuff + extensionHistory
	else
		fName = fName + "_" + stuff

	return fName

_minxiAttachmentInfo = (formData, instance, attach) ->
	user = db.users.findOne({_id: attach.metadata.owner})
	formData.attachInfo.push {instance: instance._id, attach_name: encodeURI(attach.name()), owner: attach.metadata.owner, owner_username: encodeURI(user.username || user.steedos_id), is_private: attach.metadata.is_private || false}

_minxiInstanceData = (formData, instance) ->
	if !formData || !instance
		return

	format = "YYYY-MM-DD HH:mm:ss"

	formData.fileID = instance._id

	field_values = InstanceManager.handlerInstanceByFieldMap(instance);

	formData = _.extend formData, field_values

	fieldNames = _.keys(formData)

	fieldNames.forEach (key)->
		fieldValue = formData[key]

		if _.isDate(fieldValue)
			fieldValue = moment(fieldValue).format(format)

		if _.isObject(fieldValue)
			fieldValue = fieldValue?.name

		if _.isArray(fieldValue) && fieldValue.length > 0 && _.isObject(fieldValue)
			fieldValue = fieldValue?.getProperty("name")?.join(",")

		if _.isArray(fieldValue)
			fieldValue = fieldValue?.join(",")

		if !fieldValue
			fieldValue = ''

		formData[key] = encodeURI(fieldValue)

	formData.attach = new Array()

	formData.attachInfo = new Array();

	#	提交人信息
	user_info = db.users.findOne({_id: instance.applicant})

	#	正文附件
	mainFile = cfs.instances.find({
		'metadata.instance': instance._id,
		'metadata.current': true,
		"metadata.main": true
	}).fetch()

	mainFile.forEach (f) ->
		try
			formData.attach.push request(Meteor.absoluteUrl("api/files/instances/") + f._id + "/" + encodeURI(f.name()))

			_minxiAttachmentInfo formData, instance, f
		catch e
			logger.error "正文附件下载失败：#{f._id},#{f.name()}. error: " + e
		#		正文附件历史版本
		mainFileHistory = cfs.instances.find({
			'metadata.instance': instance._id,
			'metadata.current': {$ne: true},
			"metadata.main": true,
			"metadata.parent": f.metadata.parent
		}, {sort: {uploadedAt: -1}}).fetch()

		mainFileHistoryLength = mainFileHistory.length

		mainFileHistory.forEach (fh, i) ->
			fName = getFileHistoryName f.name(), fh.name(), mainFileHistoryLength - i
			try
				formData.attach.push request(Meteor.absoluteUrl("api/files/instances/") + fh._id + "/" + encodeURI(fName))
				_minxiAttachmentInfo formData, instance, f
			catch e
				logger.error "正文附件下载失败：#{f._id},#{f.name()}. error: " + e

	#	非正文附件
	nonMainFile = cfs.instances.find({
		'metadata.instance': instance._id,
		'metadata.current': true,
		"metadata.main": {$ne: true}
	})

	nonMainFile.forEach (f)->
		try
			formData.attach.push request(Meteor.absoluteUrl("api/files/instances/") + f._id + "/" + encodeURI(f.name()))
			_minxiAttachmentInfo formData, instance, f
		catch e
			logger.error "附件下载失败：#{f._id},#{f.name()}. error: " + e
		#	非正文附件历史版本
		nonMainFileHistory = cfs.instances.find({
			'metadata.instance': instance._id,
			'metadata.current': {$ne: true},
			"metadata.main": {$ne: true},
			"metadata.parent": f.metadata.parent
		}, {sort: {uploadedAt: -1}}).fetch()

		nonMainFileHistoryLength = nonMainFileHistory.length

		nonMainFileHistory.forEach (fh, i) ->
			fName = getFileHistoryName f.name(), fh.name(), nonMainFileHistoryLength - i
			try
				formData.attach.push request(Meteor.absoluteUrl("api/files/instances/") + fh._id + "/" + encodeURI(fName))
				_minxiAttachmentInfo formData, instance, f
			catch e
				logger.error "附件下载失败：#{f._id},#{f.name()}. error: " + e


	#	原文
	form = db.forms.findOne({_id: instance.form})
	attachInfoName = "F_#{form?.name}_#{instance._id}_1.html";
	attachInfoUrl = Meteor.absoluteUrl("workflow/space/") + instance.space + "/view/readonly/" + instance._id + "/" + encodeURI(attachInfoName)

	try
		formData.attach.push request(attachInfoUrl)
	catch e
		logger.error "原文下载失败：#{f._id},#{f.name()}. error: " + e

	formData.attachInfo = JSON.stringify(formData.attachInfo)

	return formData;


InstancesToArchive._sendContractInstance = (url, instance, callback) ->

#	表单数据
	formData = {}

	_minxiInstanceData(formData, instance)

	if _checkParameter(formData)

		logger.debug("_sendContractInstance: #{instance._id}")

		#	发送数据
		httpResponse = steedosRequest.postFormDataAsync url, formData, callback

		if httpResponse.statusCode == 200
			InstancesToArchive.success instance
		else
			InstancesToArchive.failed instance, httpResponse
	else
		InstancesToArchive.failed instance, "立档单位 不能为空"


InstancesToArchive::sendContractInstances = (to_archive_api) ->
	console.time("sendContractInstances")
	instances = @getContractInstances()

	that = @
	console.log "instances.length is #{instances.count()}"
	instances.forEach (instance, i)->
		url = that.archive_server + to_archive_api + '?externalId=' + instance._id
		InstancesToArchive._sendContractInstance url, instance

	console.timeEnd("sendContractInstances")


InstancesToArchive::sendNonContractInstances = (to_archive_api) ->
	console.time("sendNonContractInstances")
	instances = @getNonContractInstances()
	that = @
	logger.info "instances.length is #{instances.count()}"
	instances.forEach (instance)->
		url = that.archive_server + to_archive_api + '?externalId=' + instance._id
		logger.debug "url is #{url}"
		InstancesToArchive.sendNonContractInstance url, instance

	console.timeEnd("sendNonContractInstances")


InstancesToArchive.sendNonContractInstance = (url, instance, callback) ->
	format = "YYYY-MM-DD HH:mm:ss"

	#	表单数据
	formData = {}

	#	设置归档日期
	now = new Date()

	formData.guidangriqi = moment(now).format(format)

	formData.LAST_FILE_DATE = moment(instance.modified).format(format)

	formData.FILE_DATE = moment(instance.submit_date).format(format)

	formData.TITLE_PROPER = instance.name || "无"

	_minxiInstanceData(formData, instance)

	if _checkParameter(formData)

		logger.debug("_sendContractInstance: #{instance._id}")

		#	发送数据
		httpResponse = steedosRequest.postFormDataAsync url, formData, callback

		if httpResponse.statusCode == 200
			InstancesToArchive.success instance
		else
			InstancesToArchive.failed instance, httpResponse
	else
		InstancesToArchive.failed instance, "立档单位 不能为空"