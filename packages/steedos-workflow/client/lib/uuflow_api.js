UUflow_api = {};

// 新建instance（申请单）
UUflow_api.post_draft = function (flowId) {
	var uobj = {};
	uobj.methodOverride = "POST";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/drafts?" + $.param(uobj);
	var data = {
		"Instances": [{
			"flow": flowId,
			"applicant": Meteor.userId(),
			"space": Session.get("spaceId")
		}]
	};
	data = JSON.stringify(data);
	$(document.body).addClass("loading");

	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			$(document.body).removeClass("loading");
			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			FlowRouter.go("/workflow/space/" + Session.get("spaceId") + "/draft/" + responseText.inserts[0]);

			toastr.success(TAPi18n.__('Added successfully'));
		},
		error: function (xhr, msg, ex) {
			$(document.body).removeClass("loading");
			toastr.error(msg);
		}
	})
};

// 拟稿状态下暂存instance（申请单）
UUflow_api.put_draft = function (instance) {
	var uobj = {};
	uobj.methodOverride = "PUT";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Steedos.settings.webservices.uuflow.url + "/uf/drafts?" + $.param(uobj);
	var data = {
		"Instances": [instance]
	};
	data = JSON.stringify(data);
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}
			toastr.success(TAPi18n.__('Saved successfully'));
		},
		error: function (xhr, msg, ex) {
			toastr.error(msg);
		}
	})
};

// 拟稿状态下删除instance（申请单）
UUflow_api.delete_draft = function (instanceId) {
	var uobj = {};
	uobj.methodOverride = "DELETE";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/remove?" + $.param(uobj);
	var data = {
		"Instances": [{
			"id": instanceId
		}]
	};
	data = JSON.stringify(data);
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			FlowRouter.go("/workflow/space/" + Session.get("spaceId") + "/" + Session.get("box"));
			toastr.success(TAPi18n.__('Deleted successfully'));
		},
		error: function (xhr, msg, ex) {
			toastr.error(msg);
		}
	})
};

// instance（申请单）的第一次提交
UUflow_api.post_submit = function (instance) {
	var uobj = {};
	uobj.methodOverride = "POST";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/submit?" + $.param(uobj);
	var data = {
		"Instances": [instance]
	};
	data = JSON.stringify(data);
	$(document.body).addClass("loading");
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			$(document.body).removeClass("loading");

			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			if (responseText.result && responseText.result.length > 0) {
				_.each(responseText.result, function (r) {
					if (r.alerts) {
						toastr.info(r.alerts);
					}
				});

				FlowRouter.go("/workflow/space/" + Session.get('spaceId') + "/draft/");
				return;
			}

			FlowRouter.go("/workflow/space/" + Session.get("spaceId") + "/" + Session.get("box"));

			toastr.success(TAPi18n.__('Submitted successfully'));
		},
		error: function (xhr, msg, ex) {
			$(document.body).removeClass("loading");
			toastr.error(msg);
		}
	})
};

// 审核状态下暂存instance（申请单）
UUflow_api.put_approvals = function (approve) {
	var uobj = {};
	uobj.methodOverride = "PUT";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Steedos.settings.webservices.uuflow.url + "/uf/approvals?" + $.param(uobj);
	var data = {
		"Approvals": [approve]
	};
	data = JSON.stringify(data);

	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			toastr.success(TAPi18n.__('Saved successfully'));
		},
		error: function (xhr, msg, ex) {
			toastr.error(msg);
		}
	})
};

// 待审核提交
UUflow_api.post_engine = function (approve) {
	var uobj = {};
	uobj.methodOverride = "POST";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/engine?" + $.param(uobj);
	var data = {
		"Approvals": [approve]
	};
	data = JSON.stringify(data);
	$(document.body).addClass("loading");
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			$(document.body).removeClass("loading");

			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			FlowRouter.go("/workflow/space/" + Session.get("spaceId") + "/" + Session.get("box"));
			toastr.success(TAPi18n.__('Submitted successfully'));
		},
		error: function (xhr, msg, ex) {
			$(document.body).removeClass("loading");
			toastr.error(msg);
		}
	})
};

// 取消申请
UUflow_api.post_terminate = function (instance) {
	var uobj = {};
	uobj.methodOverride = "POST";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/terminate?" + $.param(uobj);
	var data = {
		"Instances": [instance]
	};
	data = JSON.stringify(data);

	$(document.body).addClass("loading");
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			$(document.body).removeClass("loading");

			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			FlowRouter.go("/workflow/space/" + Session.get("spaceId") + "/" + Session.get("box"));

			toastr.success(TAPi18n.__('Canceled successfully'));
		},
		error: function (xhr, msg, ex) {
			$(document.body).removeClass("loading");
			toastr.error(msg);
		}
	})
};

// 转签核
UUflow_api.put_reassign = function (instance) {
	var uobj = {};
	uobj.methodOverride = "PUT";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/reassign?" + $.param(uobj);
	var data = {
		"Instances": [instance]
	};
	data = JSON.stringify(data);

	$(document.body).addClass("loading");
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			$(document.body).removeClass("loading");

			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			FlowRouter.go("/workflow/space/" + Session.get("spaceId") + "/" + Session.get("box"));
			toastr.success(TAPi18n.__('Reasigned successfully'));
		},
		error: function (xhr, msg, ex) {
			$(document.body).removeClass("loading");
			toastr.error(msg);
		}
	})
};

// 重定位
UUflow_api.put_relocate = function (instance) {
	var uobj = {};
	uobj.methodOverride = "PUT";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/relocate?" + $.param(uobj);
	var data = {
		"Instances": [instance]
	};
	data = JSON.stringify(data);

	$(document.body).addClass("loading");
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			$(document.body).removeClass("loading");

			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			FlowRouter.go("/workflow/space/" + Session.get("spaceId") + "/" + Session.get("box"));

			toastr.success(TAPi18n.__('Relocated successfully'));
		},
		error: function (xhr, msg, ex) {
			$(document.body).removeClass("loading");
			toastr.error(msg);
		}
	})
};

// 归档
UUflow_api.post_archive = function (insId) {
	var uobj = {};
	uobj.methodOverride = "POST";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/archive?" + $.param(uobj);
	var data = {
		"Instances": [{
			id: insId
		}]
	};
	data = JSON.stringify(data);
	$(document.body).addClass("loading");
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			$(document.body).removeClass("loading");

			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
			}
		},
		error: function (xhr, msg, ex) {
			$(document.body).removeClass("loading");
			toastr.error(msg);
		}
	})
};

// 导出报表
UUflow_api.get_export = function (spaceId, flowId, type) {
	var uobj = {};
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	uobj.space_id = spaceId;
	uobj.flow_id = flowId;
	uobj.timezoneoffset = new Date().getTimezoneOffset();
	uobj.type = type;
	var url = Meteor.absoluteUrl() + "api/workflow/export/instances?" + $.param(uobj);
	window.open(url, '_parent', 'EnableViewPortScale=yes');
};

// 打印
UUflow_api.print = function (instanceId) {
	var uobj = {};
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	uobj.id = instanceId;
	window.open(Steedos.settings.webservices.uuflow.url + "/uf/print?" + $.param(uobj), '_blank', 'EnableViewPortScale=yes');
};

// 计算下一步处理人
UUflow_api.caculate_nextstep_users = function (deal_type, spaceId, body) {
	var q = {};
	q.deal_type = deal_type;
	q.spaceId = spaceId;

	var nextStepUsers = [];
	var data = JSON.stringify(body);
	$.ajax({
		url: Meteor.absoluteUrl('api/workflow/nextStepUsers') + '?' + $.param(q),
		type: 'POST',
		async: false,
		data: data,
		dataType: 'json',
		processData: false,
		contentType: "application/json",
		success: function (responseText, status) {
			if (responseText.errors) {
				toastr.error(responseText.errors);
				return;
			}

			nextStepUsers = responseText.nextStepUsers;
		},
		error: function (xhr, msg, ex) {
			toastr.error(msg);
		}
	});

	return nextStepUsers;
};

// 获取space_users
UUflow_api.getSpaceUsers = function (spaceId, userIds) {
	var q = {};
	q.spaceId = spaceId;
	var data = {
		'userIds': userIds
	};
	var spaceUsers;
	data = JSON.stringify(data);
	$.ajax({
		url: Meteor.absoluteUrl('api/workflow/getSpaceUsers') + '?' + $.param(q),
		type: 'POST',
		async: false,
		data: data,
		dataType: 'json',
		processData: false,
		contentType: "application/json",
		success: function (responseText, status) {
			if (responseText.errors) {
				toastr.error(responseText.errors);
				return;
			}

			spaceUsers = responseText.spaceUsers;
		},
		error: function (xhr, msg, ex) {
			toastr.error(msg);
		}
	});

	return spaceUsers;
};

// 取回
UUflow_api.post_retrieve = function (instance) {
	var uobj = {};
	uobj.methodOverride = "POST";
	uobj["X-User-Id"] = Meteor.userId();
	uobj["X-Auth-Token"] = Accounts._storedLoginToken();
	var url = Meteor.absoluteUrl() + "api/workflow/retrieve?" + $.param(uobj);
	var data = {
		"Instances": [{
			_id: instance._id,
			retrieve_comment: instance.retrieve_comment
		}]
	};
	data = JSON.stringify(data);

	$(document.body).addClass("loading");
	$.ajax({
		url: url,
		type: "POST",
		async: true,
		data: data,
		dataType: "json",
		processData: false,
		contentType: "application/json",

		success: function (responseText, status) {
			$(document.body).removeClass("loading");

			if (responseText.errors) {
				responseText.errors.forEach(function (e) {
					toastr.error(e.errorMessage);
				});
				return;
			}

			FlowRouter.go("/workflow/space/" + Session.get("spaceId") + "/inbox");

			toastr.success(TAPi18n.__('Retrieved successfully'));
		},
		error: function (xhr, msg, ex) {
			$(document.body).removeClass("loading");
			toastr.error(msg);
		}
	})
};