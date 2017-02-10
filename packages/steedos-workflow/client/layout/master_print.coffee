Template.printLayout.onCreated ->
	self = this;

	self.minHeight = new ReactiveVar(
		$(window).height());

	$(window).resize ->
		self.minHeight.set($(window).height());

Template.printLayout.onRendered ->

	self = this;
	self.minHeight.set($(window).height());

	$('body').removeClass('fixed');
	$(window).resize();


Template.printLayout.helpers 
	minHeight: ->
		return Template.instance().minHeight.get() + 'px'
	
	subsReady: ->
		return Steedos.subsBootstrap.ready() && Steedos.subs["Instance"].ready()