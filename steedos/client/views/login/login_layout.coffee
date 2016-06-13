Template.loginLayout.helpers
                

Template.loginLayout.onCreated ->
        self = this;

        $(window).resize ->
                $(".content-wrapper").css("min-height", ($(window).height()) + "px");


Template.loginLayout.onRendered ->

        $(window).resize();

        if ($("body").hasClass('sidebar-open')) 
                $("body").removeClass('sidebar-open');

Template.loginLayout.events

        'click #btnLogout': (e, t) ->
                FlowRouter.go("/steedos/logout")

        'click #btnSignIn': (e, t) ->
                FlowRouter.go("/steedos/sign-in")
                
        'click #btnSignUp': (e, t) ->
                FlowRouter.go("/steedos/sign-up")

        'click #previousVersion': (e,t)->
                Steedos.openWindow(Meteor.absoluteUrl("system/steedos/"))