# if (steedos_form)
#	formula_fields = Form_formula.getFormulaFieldVariable("Form_formula.field_values", steedos_form.fields);

formId = 'instanceform';

Template.instanceform.helpers
	instanceId: ->
		return 'instanceform';#"instance_" + Session.get("instanceId");
	
	steedos_form: ->
		form_version = WorkflowManager.getInstanceFormVersion();
		if form_version
			return form_version

	innersubformContext: (obj)->
		doc_values = WorkflowManager_format.getAutoformSchemaValues();;
		obj["tableValues"] = if doc_values then doc_values[obj.code] else []
		obj["formId"] = formId;
		return obj;

	instance: ->
		steedos_instance = WorkflowManager.getInstance();
		return steedos_instance;

	equals: (a,b) ->
		return (a == b)

	includes: (a, b) ->
		return b.split(',').includes(a);

	fields: ->
		form_version = WorkflowManager.getInstanceFormVersion();
		if form_version
			return new SimpleSchema(WorkflowManager_format.getAutoformSchema(form_version));
	doc_values: ->
		WorkflowManager_format.getAutoformSchemaValues();

	currentStep: ->
		return InstanceManager.getCurrentStep();

	currentApprove: ->
		return InstanceManager.getCurrentApprove();

	init_nextStepsOptions: ->
		currentApprove = InstanceManager.getCurrentApprove();
		if !currentApprove
			return;

		if(currentApprove.next_steps.length < 1)
			return ;

		judge = currentApprove.judge
		instance = WorkflowManager.getInstance();
		currentStep = InstanceManager.getCurrentStep();
		form_version = WorkflowManager.getInstanceFormVersion();
		if !form_version
			return ;
		autoFormDoc = AutoForm.getFormValues("instanceform").insertDoc;
		nextSteps = ApproveManager.getNextSteps(instance, currentStep, judge, autoFormDoc, form_version.fields);

		if !nextSteps
			return ;

		ApproveManager.updateNextStepOptions(nextSteps, judge);

		nextStepId = currentApprove.next_steps[0].step;
		$("#nextSteps").get(0).value = nextStepId;

		nextStepUsers = ApproveManager.getNextStepUsers(instance, nextStepId);
		nextStep = WorkflowManager.getInstanceStep(nextStepId);
		ApproveManager.updateNextStepUsersOptions(nextStep, nextStepUsers);
		#设置选中的用户
		u_ops = $("#nextStepUsers option").toArray();

		if u_ops.length > 0
			$("#nextStepUsers").get(0).selectedIndex = -1;

		u_op.selected = true for u_op in u_ops when currentApprove.next_steps[0].users.includes(u_op.value)
		




Template.instanceform.events
	
	'change .suggestion,.form-control': (event) ->
		judge = $("[name='judge']").filter(':checked').val();
		instance = WorkflowManager.getInstance();
		currentStep = InstanceManager.getCurrentStep();
		form_version = WorkflowManager.getInstanceFormVersion();
		if !form_version
			return ;
		autoFormDoc = AutoForm.getFormValues("instanceform").insertDoc;
		nextSteps = ApproveManager.getNextSteps(instance, currentStep, judge, autoFormDoc, form_version.fields);

		if !nextSteps
			$("#nextSteps").empty();$("#nextStepUsers").empty();
			return;

		ApproveManager.updateNextStepOptions(nextSteps, judge);

		if nextSteps.length ==1 || judge == "rejected"
			nextStepId = $("#nextSteps option:selected").val();
			nextStepUsers = ApproveManager.getNextStepUsers(instance, nextStepId);
			nextStep = WorkflowManager.getInstanceStep(nextStepId);
			ApproveManager.updateNextStepUsersOptions(nextStep, nextStepUsers);

	'change #nextSteps': (event) ->
		instance = WorkflowManager.getInstance();
		nextStepId = $("#nextSteps option:selected").val();
		nextStep = WorkflowManager.getInstanceStep(nextStepId);

		nextStepUsers = ApproveManager.getNextStepUsers(instance, nextStepId);
		ApproveManager.updateNextStepUsersOptions(nextStep, nextStepUsers);

	'change .form-control': (event)->
		
		code = event.target.name;

		console.log("instanceform form-control change, code is " + code);

		form_version = WorkflowManager.getInstanceFormVersion();
		formula_fields = []
		if form_version
			formula_fields = Form_formula.getFormulaFieldVariable("Form_formula.field_values", form_version.fields);
		Form_formula.run(code, "", formula_fields, AutoForm.getFormValues("instanceform").insertDoc, form_version.fields);
	
	'click #instance_to_print': (event)->
		UUflow_api.print($("#instanceId").val());

	
	'click #instance_update': (event)->
		InstanceManager.saveIns();

	'click #instance_remove': (event)->
		InstanceManager.deleteIns();

	'click #instance_submit': (event)->
		InstanceManager.submitIns();

	# 子表删除行时，执行主表公式计算
	'click .remove-steedos-table-row': (event, template)->
		console.log("instanceform form-control change");
		code = event.target.name;

		form_version = WorkflowManager.getInstanceFormVersion();
		formula_fields = []
		if form_version
			formula_fields = Form_formula.getFormulaFieldVariable("Form_formula.field_values", form_version.fields);

		# autoform-inputs 中 markChanged 函数中，对template 的更新延迟了100毫秒，
		# 此处为了能拿到删除列后最新的数据，此处等待markChanged执行完成后，再进行计算公式.
		# 此处给定等待101毫秒,只是为了将函数添加到 Timer线程中，并且排在markChanged函数之后。

		setTimeout ->
		   console.log(JSON.stringify(AutoForm.getFormValues("instanceform").insertDoc));
		   Form_formula.run(code, "", formula_fields, AutoForm.getFormValues("instanceform").insertDoc, form_version.fields);
		,101