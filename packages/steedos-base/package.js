Package.describe({
	name: 'steedos:base',
	version: '0.0.21',
	summary: 'Steedos libraries',
	git: 'https://github.com/steedos/apps/tree/master/packages/steedos-base'
});

Npm.depends({
	cookies: "0.6.1"
});

Package.onUse(function (api) {
	api.versionsFrom('METEOR@1.3');

	api.use('session');
	api.use('coffeescript');
	api.use('ecmascript');
	api.use('blaze-html-templates');
	api.use('underscore');
	api.use('reactive-var');
	api.use('tracker');

	api.use('accounts-base');

	api.use('matb33:collection-hooks@0.8.4');
	api.use('flemay:less-autoprefixer@1.2.0');
	api.use('kadira:flow-router@2.10.1');
	api.use('meteorhacks:subs-manager@1.6.4');

	api.use('momentjs:moment@2.14.1');

	api.use('tap:i18n@1.8.2');
	api.use('aldeed:simple-schema@1.5.3');
	api.use('aldeed:tabular@1.6.1');
	api.use('momentjs:moment');
	api.use('simple:json-routes@2.1.0');

	api.use('steedos:i18n@0.0.4');

	api.addFiles('lib/steedos_util.js', ['client', 'server']);

	api.addFiles([
		'lib/core.coffee',
		'lib/tap-i18n.coffee']);

	api.addFiles('lib/models/apps.coffee');

	api.addFiles([
		'client/core.coffee',
		'client/api.coffee',
		'client/helpers.coffee',
		'client/router.coffee',
		'client/subscribe.coffee',
		'client/layout/main.html',
		'client/layout/main.less',
		'client/layout/main.coffee',
		'client/layout/layout.html',
		'client/layout/layout.less',
		'client/layout/header_logo.html',
		'client/layout/header_logo.coffee',
		'client/layout/header_refresh.html',
		'client/layout/header_refresh.coffee',
		'client/layout/header_loading.html',
		'client/layout/header.html',
		'client/layout/header.less',
		'client/layout/sidebar.html',
		'client/layout/steedosheader-account.html',
		'client/layout/steedosheader-account.coffee',
		'client/layout/steedosheader-account.less',
		'client/views/app_list_box_modal.html',
		'client/views/app_list_box_modal.coffee',
		'client/views/app_list_box_modal.less',
		'client/views/space_switcher.html',
		'client/views/space_switcher.coffee',
		'client/views/space_switcher.less'
	], "client");

	api.addFiles('client/layout/login_layout.html', "client");
	api.addFiles('client/layout/login_layout.coffee', "client");
	api.addFiles('client/layout/login_layout.less', "client");
	api.addFiles('client/layout/tabbar.html', "client");
	api.addFiles('client/layout/tabbar.coffee', "client");
	api.addFiles('client/layout/tabbar.less', "client");

	api.addFiles('lib/models/users.coffee');
	api.addFiles('lib/models/spaces.coffee');
	api.addFiles('lib/models/space_users.coffee');
	api.addFiles('lib/models/organizations.coffee');
	api.addFiles('lib/models/users_changelogs.coffee');
	api.addFiles('lib/models/steedos_keyvalue.coffee');
	api.addFiles('lib/models/steedos_statistics.coffee');
	api.addFiles('lib/models/space_user_signs.coffee');
	api.addFiles('lib/models/audit_logs.coffee');
	api.addFiles('lib/models/billings.coffee');
	api.addFiles('lib/models/modules.coffee');
	api.addFiles('lib/models/modules_changelogs.coffee');

	api.addFiles('routes/collection.coffee', 'server');

	api.addFiles('lib/ajax_collection.coffee', 'client');

	api.addFiles('lib/steedos_data_manager.js', 'client');

	api.addFiles('routes/avatar.coffee', 'server');

	api.addFiles('server/publications/apps.coffee', 'server');
	api.addFiles('server/publications/my_spaces.coffee', 'server');

	api.export('Steedos');
	api.export('db');

	api.export('AjaxCollection');
	api.export("SteedosDataManager");
});

Package.onTest(function (api) {

});