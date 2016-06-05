# BQQ.app =
#   app_id: "200626779",
#   app_secret: "UkQ6G6gFJwJBfYuv"


BQQ.company =      
  company_id: 'c4609934c326caf9fd0053823bb99947',
  company_token: '07ded6f5c4c31706018434f88a94b461',
  refresh_token: '8cfbcf279c61028750ad5bcec13d8b03',


config = ServiceConfiguration.configurations.findOne({service: 'bqq'});

BQQ.corporationGet = (oauth)->
  try
    response = HTTP.get(
      "https://openapi.b.qq.com/api/corporation/get", 
      {
        params: 
          app_id: config.clientId,
          app_secret: OAuth.openSecret(config.secret),
          company_id: oauth.company_id,
          company_token: oauth.company_token,
          client_ip: "0.0.0.0",
          oauth_version: 2
        
      }
    );

    if (response.error_code) 
      throw response.msg

    if response.data.ret > 0 
      throw response.data.msg

    return response.data.data

  catch err
    throw _.extend(new Error("Failed to complete OAuth handshake with QQ. " + err.message), {response: err.response});


BQQ.deptGet = (oauth, timestamp)->
  try
    response = HTTP.get(
      "https://openapi.b.qq.com/api/dept/list", 
      {
        params: 
          app_id: config.clientId,
          company_id: oauth.company_id,
          company_token: oauth.company_token,
          client_ip: "0.0.0.0",
          oauth_version: 2,
          timestamp: if timestamp then timestamp else 0
        
      }
    );

    if (response.error_code) 
      throw response.msg

    if response.data.ret > 0 
      throw response.data.msg

    return response.data.data

  catch err
    throw _.extend(new Error("Failed to complete OAuth handshake with QQ. " + err.message), {response: err.response});


BQQ.userGet = (oauth, timestamp)->
  try
    response = HTTP.get(
      "https://openapi.b.qq.com/api/user/list", 
      {
        params: 
          app_id: config.clientId,
          company_id: oauth.company_id,
          company_token: oauth.company_token,
          client_ip: "0.0.0.0",
          oauth_version: 2,
          timestamp: if timestamp then timestamp else 0
        
      }
    );

    if (response.error_code) 
      throw response.msg

    if response.data.ret > 0 
      throw response.data.msg

    return response.data.data

  catch err
    throw _.extend(new Error("Failed to complete OAuth handshake with QQ. " + err.message), {response: err.response});

# BQQ.syncCompany({ expires_in: 7776000,refresh_token: '8cfbcf279c61028750ad5bcec13d8b03',company_id: 'c4609934c326caf9fd0053823bb99947',company_token: '07ded6f5c4c31706018434f88a94b461' })
BQQ.syncCompany = (oauth) ->
  now = new Date

  # 工作区
  # {
  #   "company_id": "000a3d937971d3675423bccfc53798a1",
  #   "company_name": "Test_lucy_标准",
  #   "company_fullname": "测试_johnnyliu",
  #   "company_duedate": "1970-01-01"
  # }
  space_data = BQQ.corporationGet(oauth)
  console.log(JSON.stringify(space_data))
  space_id = null

  # 部门
  # {
  #   "timestamp": 1460551018,
  #   "items": [
  #     {
  #       "dept_id": 1,
  #       "p_dept_id": 0,
  #       "dept_name": "Test_lucy_标准"
  #     },
  #     {
  #       "dept_id": 1136750599,
  #       "p_dept_id": 1,
  #       "dept_name": "总经理办公室"
  #     },
  #     {
  #       "dept_id": 1754170384,
  #       "p_dept_id": 1136750599,
  #       "dept_name": "秘书组"
  #     }
  #   ]
  # }
  org_data = BQQ.deptGet(oauth)
  console.log(JSON.stringify(org_data))

  # 用户
  # {
  #   "timestamp": 1460549812,
  #   "items": [
  #     {
  #       "open_id": "0f09375d4e73599bcfa665d195fa7697",
  #       "gender": 1,
  #       "account": "test",
  #       "realname": "test",
  #       "title": ":",
  #       "p_dept_id": [
  #         1754170384,
  #         1
  #       ],
  #       "mobile": 0,
  #       "hidden": 0,
  #       "p_open_id": "",
  #       "role_id": 0
  #     }
  #   ]
  # }
  user_data = BQQ.userGet(oauth)
  console.log(JSON.stringify(user_data))
  owner_id = null
  owner_ids = []
  admin_ids = []
  user_data.items.forEach (u) ->
    user_id = null
    uq = db.users.find({"services.bqq.id": u.open_id})
    if uq.count() > 0
      
      user = uq.fetch()[0]
      user_id = user._id
      doc = {}
      if user.name != u.realname
        doc.name = u.realname

      if doc.hasOwnProperty('name')
        console.log('修改用户: ' + u.realname)
        console.log(doc)
        doc.modified = now
        db.users.direct.update(user_id, {$set: doc})
    else
      console.log('用户不存在')
      doc = {}
      doc.name = u.realname
      doc.locale = "zh-cn"
      doc.is_deleted = false
      doc.created = now
      doc.modified = now
      doc.services = {bqq:{id: u.open_id}}
      console.log(doc)
      user_id = db.users.direct.insert(doc)

    if u.role_id == 0
      owner_ids.push(user_id)
      admin_ids.push(user_id)
    else if u.role_id == 1
      admin_ids.push(user_id)
    
    u.user_id = user_id

  # 企业管理员可以有多个
  owner_id = owner_ids[0]

  # 新建工作区
  space_id = null
  s_id = "bqq-" + space_data.company_id
  sq = db.spaces.find({_id: s_id})
  if sq.count() > 0
    space_id = s_id
    s = sq.fetch()[0]
    s_doc = {}
    if s.name != space_data.company_name
      s_doc.name = space_data.company_name

    if !owner_ids.includes(s.owner)
      s_doc.owner = owner_id

    if s.admins.sort().toString() != admin_ids.sort().toString()
      s_doc.admins = admin_ids

    if s_doc.hasOwnProperty('name') || s_doc.hasOwnProperty('owner') || s_doc.hasOwnProperty('admins')
      console.log('修改工作区')
      console.log(s_doc)
      s_doc.modified = now
      s_doc.modified_by = owner_id
      db.spaces.direct.update(space_id, {$set: s_doc})
  else
    console.log('新建工作区')

    s_doc = {}
    s_doc._id = s_id
    s_doc.name = space_data.company_name
    s_doc.owner = owner_id
    s_doc.admins = admin_ids
    s_doc.is_deleted = false
    s_doc.created = now
    s_doc.created_by = owner_id
    s_doc.modified = now
    s_doc.modified_by = owner_id
    s_doc.services = { bqq:{ expires_in: oauth.expires_in, refresh_token: oauth.refresh_token, company_id: oauth.company_id, company_token: oauth.company_token }}
    console.log(s_doc)
    space_id = db.spaces.direct.insert(s_doc)


  # 删除
  deleted_su_ids = []
  deleted_org_ids = []

  su_ids = []
  org_ids = []
  user_data.items.forEach (u) ->
    su_ids.push("bqq-" + u.open_id)

  org_data.items.forEach (o) ->
    org_ids.push("bqq-" + space_data.company_id + "-" + o.dept_id)

  db.space_users.find({space: space_id}).forEach (su) ->
    if !su_ids.includes(su._id)
      deleted_su_ids.push(su._id)

  db.organizations.find({space: space_id}).forEach (o) ->
    if !org_ids.includes(o._id)
      deleted_org_ids.push(o._id)

  db.space_users.find({_id: {$in: deleted_su_ids}}).forEach (su) ->
    console.log("删除space_user: " + su.name)
    db.space_users.direct.remove({_id: su._id})

    organizationObj = db.organizations.findOne(su.organization)
    organizationObj.updateUsers()

    # users_changelogs
    ucl_doc = {}
    ucl_doc.change_date = moment().format('YYYYMMDD')
    ucl_doc.operator = owner_id
    ucl_doc.space = space_id
    ucl_doc.operation = "delete"
    ucl_doc.user = su.user
    ucl_doc.created = now
    ucl_doc.created_by = owner_id

    count = db.space_users.direct.find({space: space_id}).count()
    ucl_doc.user_count = count
    db.users_changelogs.direct.insert(ucl_doc)

  db.organizations.find({_id: {$in: deleted_org_ids}}).forEach (o) ->
    console.log("删除部门: " + o.name)
    db.organizations.direct.remove({_id: o._id})


  # 部门
  BQQ.createOrg(org_data.items, 0, space_id, space_data.company_id, owner_id)


  # 新建space_user
  user_data.items.forEach (u) ->
    su_id = "bqq-" + u.open_id
    suq = db.space_users.find({_id: su_id})
    if suq.count() == 0
      console.log('新建space_user')
      su_doc = {}
      su_doc._id = su_id
      su_doc.user = u.user_id
      su_doc.space = space_id
      su_doc.user_accepted = true
      su_doc.name = u.realname
      su_doc.created = now
      su_doc.created_by = owner_id

      p_dept_id = null
      if u.p_dept_id && u.p_dept_id.length >0
        p_dept_id = u.p_dept_id[0]
      if p_dept_id
        su_doc.organization = "bqq-" + space_data.company_id + "-" + p_dept_id
      console.log(su_doc)
      space_user_id = db.space_users.direct.insert(su_doc)
      if space_user_id
        # update org users
        if su_doc.organization
          organizationObj = db.organizations.findOne(su_doc.organization)
          organizationObj.updateUsers()

        # users_changelogs
        ucl_doc = {}
        ucl_doc.change_date = moment().format('YYYYMMDD')
        ucl_doc.operator = owner_id
        ucl_doc.space = space_id
        ucl_doc.operation = "add"
        ucl_doc.user = u.user_id
        ucl_doc.created = now
        ucl_doc.created_by = owner_id

        count = db.space_users.direct.find({space: space_id}).count()
        ucl_doc.user_count = count
        console.log(ucl_doc)
        db.users_changelogs.direct.insert(ucl_doc)
    else if suq.count() > 0
      su = suq.fetch()[0]
      su_doc = {}
      if su.name != u.realname
        su_doc.name = u.realname

      p_dept_id = null
      if u.p_dept_id && u.p_dept_id.length >0
        p_dept_id = u.p_dept_id[0]
      if p_dept_id
        new_org_id = "bqq-" + space_data.company_id + "-" + p_dept_id
        
        if su.organization != new_org_id
          su_doc.organization = new_org_id

      if su_doc.hasOwnProperty('name') || su_doc.hasOwnProperty('organization')
        console.log('修改space_user')
        r = db.space_users.direct.update(su._id, {$set: su_doc})
        if r && su_doc.organization
          organizationObj = db.organizations.findOne(su_doc.organization)
          organizationObj.updateUsers()
          old_org = db.organizations.findOne(su.organization)
          old_org.updateUsers()

  # 更新space_user直属上级
  user_data.items.forEach (u) ->
    if u.p_open_id
      console.log('更新space_user直属上级')
      console.log(u.realname)
      manager = db.space_users.findOne("bqq-"+u.p_open_id, {fields: {user: 1}})
      db.space_users.direct.update("bqq-"+u.open_id, {$set:{manager: manager.user}})
    else
      db.space_users.direct.update("bqq-"+u.open_id, {$set:{manager: null}})


  # 更新 org
  db.organizations.find({space: space_id}).forEach (org) ->
    console.log('更新部门 parents fullname children')
    updateFields = {}
    updateFields.parents = org.calculateParents()
    updateFields.fullname = org.calculateFullname()

    if !_.isEmpty(updateFields)
      db.organizations.direct.update(org._id, {$set: updateFields})

    if org.parent
      parent = db.organizations.findOne(org.parent)
      db.organizations.direct.update(parent._id, {$set: {children: parent.calculateChildren()}})

  # 模板表单和流程
  forms_count = db.forms.find({space: space_id}).count()
  if forms_count == 0
    root_org_query = db.organizations.find({space: space_id, is_company: true}, {fields: {_id: 1}})
    root_org = root_org_query.fetch()[0]
    if root_org
      db.spaces.createTemplateFormAndFlow(space_id)


  # 更新space.services.bqq user_list_timestamp dept_list_timestamp
  db.spaces.direct.update(space_id, {$set: {"services.bqq.user_list_timestamp": user_data.timestamp, "services.bqq.dept_list_timestamp": org_data.timestamp}})

BQQ.createOrg = (depts, p_dept_id, space_id, company_id, owner_id) ->
  now = new Date
  orgs = depts.filter((d) -> 
            if d.p_dept_id == p_dept_id
              return true
          )
  if orgs.length > 0
    orgs.forEach (o) ->
      org_id = null
      o_id = "bqq-" + company_id + "-" + o.dept_id
      oq = db.organizations.find({_id: o_id})
      if oq.count() > 0
        org_id = o_id
        org = oq.fetch()[0]
        org_doc = {}
        if org.name != o.dept_name
          org_doc.name = o.dept_name

        if org_doc.hasOwnProperty('name')
          console.log('修改部门: ' + o.dept_name)
          console.log(org_doc)
          org_doc.modified = now
          org_doc.modified_by = owner_id
          db.organizations.direct.update(org._id, {$set: org_doc})

      else
        console.log('新增部门')
        org_doc = {}
        org_doc._id = o_id
        org_doc.space = space_id
        org_doc.name = o.dept_name
        if p_dept_id > 0
          org_doc.parent = "bqq-" + company_id + "-" + p_dept_id
        if p_dept_id == 0
          org_doc.is_company = true
        org_doc.created = now
        org_doc.created_by = owner_id
        org_doc.modified = now
        org_doc.modified_by = owner_id
        console.log(org_doc)
        org_id = db.organizations.direct.insert(org_doc)
      if org_id
        BQQ.createOrg(depts, o.dept_id, space_id, company_id, owner_id)


