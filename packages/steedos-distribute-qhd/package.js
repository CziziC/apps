Package.describe({
	name: 'steedos:distribute-qhd',
	version: '0.0.1',
	summary: 'Steedos libraries',
	git: ''
});

Npm.depends({

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
	api.use('flemay:less-autoprefixer@1.2.0');
	api.use('simple:json-routes@2.1.0');
	api.use('nimble:restivus@0.8.7');
	api.use('aldeed:simple-schema@1.3.3');
	api.use('aldeed:collection2@2.5.0');
	api.use('aldeed:tabular@1.6.1');
	api.use('aldeed:autoform@5.8.0');
	api.use('matb33:collection-hooks@0.8.1');
	api.use('kadira:blaze-layout@2.3.0');
	api.use('kadira:flow-router@2.10.1');

	api.use('meteorhacks:ssr@2.2.0');
	api.use('tap:i18n@1.7.0');
	api.use('meteorhacks:subs-manager');

	api.use(['webapp'], 'server');

	api.use('momentjs:moment', 'client');
	api.use('mrt:moment-timezone', 'client');
	api.use('steedos:admin');
	api.use('steedos:workflow');

	api.use('tap:i18n', ['client', 'server']);

	tapi18nFiles = ['i18n/en.i18n.json', 'i18n/zh-CN.i18n.json']
	api.addFiles(tapi18nFiles, ['client', 'server']);

	api.addFiles('client/views/admin_distribute_flows.html', 'client');
	api.addFiles('client/views/admin_distribute_flows.coffee', 'client');

	api.addFiles('client/views/distribute_edit_flow_modal.html', 'client');
	api.addFiles('client/views/distribute_edit_flow_modal.coffee', 'client');

	api.addFiles('client/router.coffee', 'client');

	api.addFiles('client/admin-menu.coffee', 'client');

	api.addFiles('server/methods/distribute.coffee', 'server');

	api.addFiles('tabular.coffee', ['client', 'server']);

});

Package.onTest(function(api) {

});