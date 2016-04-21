Package.describe({
  summary: "i18n, with standard translations for basic meteor packages.",
  version: "1.3.3",
  name: "softwarerero:accounts-t9n",
  git: "https://github.com/steedos/useraccounts-i18n.git",
});


Package.onUse(function(api) { 
        api.use('coffeescript');
        api.use('tap:i18n', ['client', 'server']);

        tapi18nFiles = [
                'i18n/en.i18n.json', 
                'i18n/zh-CN.i18n.json'
        ]

        api.addFiles(tapi18nFiles);

        api.addFiles('core.coffee');
});