Package.describe({
	name: 'steedos:workflow',
	version: '0.0.1',
	summary: 'Steedos workflow libraries',
	git: ''
});

Npm.depends({
	cookies: "0.6.1",
	ejs: "2.5.5",
	"ejs-lint": "0.2.0",
	"eval": "0.1.2"
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');


	api.use('reactive-var');
	api.use('reactive-dict');
	api.use('coffeescript');
	api.use('random');
	api.use('ddp');
	api.use('check');
	api.use('ddp-rate-limiter');
	api.use('underscore');
	api.use('tracker');
	api.use('session');
	api.use('blaze');
	api.use('templating');
	api.use('steedos:lib');
	api.use('steedos:api');
	api.use('flemay:less-autoprefixer@1.2.0');
	api.use('simple:json-routes@2.1.0');
	api.use('nimble:restivus@0.8.7');
	api.use('aldeed:simple-schema@1.3.3');
	api.use('aldeed:collection2@2.5.0');
	api.use('aldeed:tabular@1.6.1');
	api.use('aldeed:autoform@5.8.0');
	api.use('matb33:collection-hooks@0.8.1');
	api.use('cfs:standard-packages@0.5.9');
	api.use('kadira:blaze-layout@2.3.0');
	api.use('kadira:flow-router@2.10.1');
	api.use('iyyang:cfs-aliyun')
	api.use('cfs:s3');

	api.use('meteorhacks:ssr@2.2.0');
	api.use('tap:i18n@1.7.0');
	api.use('meteorhacks:subs-manager');

	api.use(['webapp'], 'server');

	api.use('momentjs:moment', ['client', 'server']);
	api.use('mrt:moment-timezone', ['client', 'server']);

	api.use('steedos:autoform-modals');
	api.use('steedos:universe-autoform-select');

	api.use('steedos:autoform')
	api.use('steedos:base');
	api.use('steedos:lib');
	api.use('steedos:admin');

	api.use('steedos:mailqueue');
	api.use('steedos:webhookqueue');

	api.use('tap:i18n', ['client', 'server']);
	//api.add_files("package-tap.i18n", ["client", "server"]);
	tapi18nFiles = ['i18n/en.i18n.json', 'i18n/zh-CN.i18n.json']
	api.addFiles(tapi18nFiles, ['client', 'server']);


	// COMMON
	api.addFiles('lib/collection_helpers.js');

	api.addFiles('lib/tapi18n.coffee');
	api.addFiles('lib/core.coffee');


	api.addFiles('lib/models/forms.coffee');
	api.addFiles('lib/models/flows.coffee');
	api.addFiles('lib/models/flow_roles.coffee');
	api.addFiles('lib/models/flow_positions.coffee');
	api.addFiles('lib/models/instances.coffee');
	api.addFiles('lib/models/categories.coffee');
	api.addFiles('lib/models/spaces.coffee');
	api.addFiles('lib/models/deleted_instances.coffee');
	api.addFiles('lib/models/auth_tokens.coffee');
	api.addFiles('lib/models/webhooks.coffee');
	api.addFiles('lib/models/instance_number_rules.coffee');

	api.addFiles('lib/cfs/core.coffee');
	api.addFiles('lib/cfs/instances.coffee');

	api.addFiles('client/api.js', 'client');

	api.addFiles('client/lib/traces_manager.coffee', 'client');

	api.addFiles('client/lib/instance_event.js', 'client');
	api.addFiles('client/lib/1_form_formula.js', 'client');
	api.addFiles('client/lib/2_steedos_data_format.js', 'client');
	api.addFiles('client/lib/approve_manager.js', 'client');
	api.addFiles('client/lib/instance_manager.js', 'client');
	api.addFiles('client/lib/uuflow_api.js', 'client');
	api.addFiles('client/lib/workflow_manager.js', ['client', 'server']);
	api.addFiles('client/lib/node_manager.js', 'client');
	api.addFiles('client/lib/instance_readonly_template.coffee', ['client', 'server']);
	api.addFiles('client/lib/template_manager.coffee', ['client', 'server']);
	api.addFiles('client/lib/office_online.js', 'client');
	api.addFiles('client/lib/instance_number_rules.coffee', 'client');

	api.addFiles('client/lib/instance_macro.coffee', 'client');


	//add client file
	api.addFiles('client/layout/master_print.less', 'client');
	api.addFiles('client/layout/master_print.html', 'client');
	api.addFiles('client/layout/master_print.coffee', 'client');
	api.addFiles('client/views/instance/instance_print.html', 'client');
	api.addFiles('client/views/instance/instance_print.coffee', 'client');

	api.addFiles('client/coreform/inputTypes/coreform-checkbox/boolean-checkbox.html', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-checkbox/boolean-checkbox.js', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-datepicker/coreform-datepicker.js', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-multiSelect/select-checkbox-inline.html', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-multiSelect/select-checkbox-inline.js', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-number/coreform-number.js', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-radio/select-radio-inline.html', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-radio/select-radio-inline.js', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-section/steedos-section.html', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-section/steedos-section.js', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-section/steedos-section.less', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-table/steedos-table-modal.html', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-table/steedos-table-modal.js', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-table/steedos-table.html', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-table/steedos-table.js', ['client', 'server']);
	api.addFiles('client/coreform/inputTypes/coreform-table/steedos-table.less', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-textarea/coreform-textarea.html', 'client');
	api.addFiles('client/coreform/inputTypes/coreform-textarea/coreform-textarea.js', 'client');

	api.addFiles('client/layout/master.html', 'client');
	api.addFiles('client/layout/master.coffee', 'client');
	api.addFiles('client/layout/master.less', 'client');
	api.addFiles('client/layout/sidebar.html', 'client');
	api.addFiles('client/layout/sidebar.coffee', 'client');
	api.addFiles('client/layout/sidebar.less', 'client');

	api.addFiles('client/views/instance/image_sign.html', 'client');
	api.addAssets('client/views/instance/image_sign.html', 'server');
	api.addFiles('client/views/instance/_image_sign.coffee', ['client', 'server']);
	api.addFiles('client/views/instance/image_sign.coffee', 'client');

	api.addFiles('client/views/instance/_instance_form.coffee', ['client', 'server']);

	api.addFiles('client/views/instance/instance_attachments.html', 'client');
	api.addAssets('client/views/instance/instance_attachments.html', 'server');

	api.addFiles('client/views/instance/_instance_attachments.js', ['client', 'server']);
	api.addFiles('client/views/instance/_instance_sign_text.coffee', ['client', 'server']);

	api.addFiles('client/views/instance/select_flow_modal.less', 'client')
	api.addFiles('client/views/instance/select_flow_modal.html', 'client')
	api.addFiles('client/views/instance/select_flow_modal.coffee', 'client')

	api.addFiles('client/views/instance/attachments.html', 'client');
	api.addFiles('client/views/instance/attachments.js', 'client');
	api.addFiles('client/views/instance/force_end_modal.html', 'client');
	api.addFiles('client/views/instance/force_end_modal.js', 'client');
	api.addFiles('client/views/instance/instance_button.html', 'client');
	api.addFiles('client/views/instance/instance_button.coffee', 'client');
	api.addFiles('client/views/instance/instance_form.html', 'client');
	api.addFiles('client/views/instance/instance_form.coffee', 'client');
	api.addFiles('client/views/instance/instance_form.less', 'client');
	api.addFiles('client/views/instance/instance_form_table.html', 'client');
	api.addFiles('client/views/instance/instance_form_table.coffee', 'client');

	api.addFiles('client/views/instance/instance_suggestion.html', 'client');
	api.addFiles('client/views/instance/instance_suggestion.coffee', 'client');
	api.addFiles('client/views/instance/instance_view.html', 'client');
	api.addFiles('client/views/instance/instance_view.coffee', 'client');

	api.addFiles('client/views/instance/reassign_modal.html', 'client');
	api.addFiles('client/views/instance/reassign_modal.js', 'client');
	api.addFiles('client/views/instance/relocate_modal.html', 'client');
	api.addFiles('client/views/instance/relocate_modal.js', 'client');
	api.addFiles('client/views/instance/_traces_help.coffee', ['client', 'server']);
	api.addFiles('client/views/instance/traces.html', 'client');
	api.addFiles('client/views/instance/traces.js', 'client');
	api.addFiles('client/views/instance/traces_table.html', 'client');
	api.addFiles('client/views/instance/traces_table.js', 'client');

	api.addAssets('client/views/instance/traces.html', 'server');
	api.addAssets('client/views/instance/traces_table.html', 'server');

	api.addFiles('client/views/instance/trace_detail_modal.html', 'client');
	api.addFiles('client/views/instance/trace_detail_modal.js', 'client');

	api.addFiles('client/views/instance/cc_modal.html', 'client');
	api.addFiles('client/views/instance/cc_modal.coffee', 'client');
	api.addFiles('client/views/instance/opinion_modal.html', 'client');
	api.addFiles('client/views/instance/opinion_modal.js', 'client');

	api.addFiles('client/views/instance/instance_sign_modal.html', 'client');
	api.addFiles('client/views/instance/instance_sign_modal.less', 'client');
	api.addFiles('client/views/instance/instance_sign_modal.coffee', 'client');

	api.addFiles('client/views/instance/history_sign_approve.html', 'client');
	api.addFiles('client/views/instance/history_sign_approve.coffee', 'client');

	api.addFiles('client/views/list/flow_list_box.html', 'client');
	api.addFiles('client/views/list/flow_list_box.coffee', 'client');
	api.addFiles('client/views/list/flow_list_box.less', 'client');

	api.addFiles('client/views/list/flow_list_box_modal.html', 'client');
	api.addFiles('client/views/list/flow_list_box_modal.coffee', 'client');

	api.addFiles('client/views/list/forward_select_flow_modal.less', 'client');
	api.addFiles('client/views/list/forward_select_flow_modal.html', 'client');
	api.addFiles('client/views/list/forward_select_flow_modal.js', 'client');

	api.addFiles('client/views/list/attachments_upload_modal.html', 'client');
	api.addFiles('client/views/list/attachments_upload_modal.coffee', 'client');


	api.addFiles('client/views/list/flow_list_modal.html', 'client');
	api.addFiles('client/views/list/flow_list_modal.coffee', 'client');
	api.addFiles('client/views/list/flow_list_modal.less', 'client');

	api.addFiles('client/views/list/instance_list.less', 'client');
	api.addFiles('client/views/list/instance_list.html', 'client');
	api.addFiles('client/views/list/instance_list.coffee', 'client');

	api.addFiles('client/views/list/monitor.html', 'client');
	api.addFiles('client/views/list/monitor.js', 'client');

	api.addFiles('client/views/search/instance_more_search_modal.html', 'client');
	api.addFiles('client/views/search/instance_more_search_modal.js', 'client');

	api.addFiles('client/views/home.html', 'client');
	api.addFiles('client/views/home.coffee', 'client');


	api.addFiles('client/views/menu.html', 'client');
	api.addFiles('client/views/menu.coffee', 'client');
	api.addFiles('client/views/menu.less', 'client');

	api.addFiles('client/views/workflow_menu_by_flow.html', 'client');
	api.addFiles('client/views/workflow_menu_by_flow.coffee', 'client');

	api.addFiles('client/views/workflow_main.html', 'client');
	api.addFiles('client/views/workflow_main.coffee', 'client');
	api.addFiles('client/views/workflow_main.less', 'client');

	api.addFiles('client/admin_menu.coffee', 'client');
	api.addFiles('client/router.coffee', 'client');
	api.addFiles('client/subscribe.coffee', 'client');

	api.addFiles('client/views/list/admin_import_flow_modal.html', 'client');
	api.addFiles('client/views/list/admin_import_flow_modal.coffee', 'client');
	api.addFiles('client/views/list/admin_flows.html', 'client');
	api.addFiles('client/views/list/admin_flows.coffee', 'client');
	api.addFiles('client/views/list/admin_import_export_flows.html', 'client');
	api.addFiles('client/views/list/admin_import_export_flows.coffee', 'client');

	api.addFiles('client/views/list/admin_categories.html', 'client');
	api.addFiles('client/views/list/admin_categories.coffee', 'client');

	api.addFiles('client/views/list/related_instances_modal.less', 'client');
	api.addFiles('client/views/list/related_instances_modal.html', 'client');
	api.addFiles('client/views/list/related_instances_modal.coffee', 'client');

	api.addFiles('client/views/instance/_related_instances.coffee', ['client', 'server']);

	api.addFiles('client/views/instance/related_instances.html', 'client');
	api.addAssets('client/views/instance/related_instances.html', 'server');
	api.addFiles('client/views/instance/related_instances.coffee', 'client');

	api.addFiles('client/views/instance/remind_modal.html', 'client');
	api.addFiles('client/views/instance/remind_modal.coffee', 'client');

	api.addFiles('client/views/list/admin_instance_number_rules.html', 'client');
	api.addFiles('client/views/list/admin_instance_number_rules.coffee', 'client');


	//add server file
	api.addFiles('server/methods/get_instance_data.js', 'server');
	api.addFiles('server/methods/save_instance.js', 'server');
	api.addFiles('server/methods/trace_approve_cc.js', 'server');
	api.addFiles('server/methods/forward_instance.js', 'server');
	api.addFiles('server/methods/cfs_instances.js', 'server');
	api.addFiles('server/methods/instance_approve.coffee', 'server');
	api.addFiles('server/methods/instance_return.coffee', 'server');
	api.addFiles('server/methods/instance_remind.coffee', 'server');
	api.addFiles('server/methods/next_step_users_not_found.coffee', 'server');
	api.addFiles('server/methods/instance_number_rules.coffee', 'server');
	api.addFiles('server/methods/check_main_attach.coffee', 'server');
	api.addFiles('server/methods/related_instances.coffee', 'server');

	api.addFiles('server/routes/instance.coffee', 'server');

	// routes
	api.addFiles('routes/nextStepUsers.js', 'server');
	api.addFiles('routes/getSpaceUsers.js', 'server');
	api.addFiles('routes/getFormulaUserObjects.js', 'server');
	api.addFiles('routes/init_formula_values.js', 'server');

	api.addFiles('routes/api_workflow_engine.coffee', 'server');
	api.addFiles('routes/api_workflow_drafts.coffee', 'server');
	api.addFiles('routes/api_workflow_remove.coffee', 'server');
	api.addFiles('routes/api_workflow_submit.coffee', 'server');
	api.addFiles('routes/api_workflow_terminate.coffee', 'server');
	api.addFiles('routes/api_workflow_reassign.coffee', 'server');
	api.addFiles('routes/api_workflow_relocate.coffee', 'server');
	api.addFiles('routes/api_workflow_archive.coffee', 'server');
	api.addFiles('routes/api_workflow_export.coffee', 'server');
	api.addFiles('routes/api_workflow_space_changeset.coffee', 'server');
	api.addFiles('routes/api_workflow_retrieve.coffee', 'server');
	api.addFiles('routes/api_workflow_open_pending.coffee', 'server');

	api.addFiles('routes/api_workflow_open_drafts.coffee', 'server');

	api.addFiles('routes/api_workflow_open_get.coffee', 'server');

	api.addFiles('routes/api_workflow_instances.coffee', 'server');

	api.addFiles('server/lib/workflow_manager.js', 'server');
	api.addFiles('server/lib/1_form_formula.js', 'server');
	api.addFiles('server/lib/get_handlers_manager.coffee', 'server');
	api.addFiles('server/lib/uuflow_manager.coffee', 'server');
	api.addFiles('server/lib/push_manager.coffee', 'server');
	api.addFiles('server/lib/permission_manager.coffee', 'server');

	api.addFiles('server/publications/categories.coffee', 'server');
	api.addFiles('server/publications/cfs_instances.coffee', 'server');
	api.addFiles('server/publications/flow_positions.coffee', 'server');
	api.addFiles('server/publications/flow_roles.coffee', 'server');
	api.addFiles('server/publications/flows.coffee', 'server');
	api.addFiles('server/publications/forms.coffee', 'server');
	api.addFiles('server/publications/instance_data.coffee', 'server');
	api.addFiles('server/publications/instance_list.coffee', 'server');
	api.addFiles('server/publications/instance_tabular.coffee', 'server');
	api.addFiles('server/publications/instance_draft.coffee', 'server');

	api.addFiles('server/lib/export.coffee', 'server');
	api.addFiles('routes/export.coffee', 'server');
	api.addFiles('server/lib/import.coffee', 'server');
	api.addFiles('routes/import.coffee', 'server');
	// EJS
	api.addAssets('server/ejs/export_instances.ejs', 'server');

	api.addFiles('lib/admin.coffee');

	api.addFiles('tabular.coffee');

	api.addFiles('client/views/instance/instance_sign_text.html', 'client');
	api.addAssets('client/views/instance/instance_sign_text.html', 'server');
	api.addFiles('client/views/instance/instance_sign_text.coffee', 'client');

	api.export("WorkflowManager");
	api.export("InstanceManager");
	api.export("WorkflowManager_format");
	// EXPORT
	api.export('Workflow');
	api.export('SteedosTable');
	api.export('InstanceReadOnlyTemplate');
	api.export('TemplateManager');

	api.export('CoreForm');

	api.export('InstanceNumberRules');

	api.addFiles('server/flow-template/workflow_template.coffee', 'server');

	// workflow_template（zh-CN）
	api.addFiles('server/flow-template/zh-CN/payment_request.coffee', 'server');
	api.addFiles('server/flow-template/zh-CN/travel_expenses.coffee', 'server');
	api.addFiles('server/flow-template/zh-CN/car_rental_request.coffee', 'server');
	api.addFiles('server/flow-template/zh-CN/outgoing_request.coffee', 'server');
	api.addFiles('server/flow-template/zh-CN/invoice_request.coffee', 'server');
	api.addFiles('server/flow-template/zh-CN/daily_expenses.coffee', 'server');
	api.addFiles('server/flow-template/zh-CN/leave_request.coffee', 'server');
	api.addFiles('server/flow-template/zh-CN/request_report.coffee', 'server');
	api.addFiles('server/flow-template/zh-CN/purchase_request.coffee', 'server');

	// workflow_template（en）
	api.addFiles('server/flow-template/en/capex.coffee', 'server');
	api.addFiles('server/flow-template/en/leave_request.coffee', 'server');
	api.addFiles('server/flow-template/en/loan_request.coffee', 'server');
	api.addFiles('server/flow-template/en/pay_my_invoice.coffee', 'server');
	api.addFiles('server/flow-template/en/salary_advance.coffee', 'server');
	api.addFiles('server/flow-template/en/travel_expenses.coffee', 'server');

	api.addFiles('server/startup.coffee', 'server');

	api.addFiles('server/lib/instance_manager.coffee', 'server');

	api.export(['uuflowManager', 'getHandlersManager', 'pushManager', 'permissionManager', 'steedosExport', 'steedosImport', 'workflowTemplate', 'InstanceManager'], ['server']);

});

Package.onTest(function(api) {

});