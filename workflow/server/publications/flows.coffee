  Meteor.publish 'flows', (spaceId)->
  
    unless this.userId
      return this.ready()
    
    unless spaceId
      return this.ready()

    # 第一次订阅时初始化工作区
    if db.flows.find({spaceId: spaceId}).count() == 0
        db.spaces.createTemplateOrganizations(spaceId)
        db.spaces.createTemplateFormAndFlow(spaceId)

    console.log '[publish] flows for space ' + spaceId

    return db.flows.find({space: spaceId}, {fields: {name: 1, form: 1, state: 1}})