class RpThreads
  constructor:->
    @config={}

  _resolveResult=(err,res,callback)->
    if callback
      if res then callback.call @,null,res else callback.call @,err,null


  setConfig:(baseurl,auth)->
    @config={baseUrl:baseurl,auth:auth}


  identify:(payload,userId=Meteor.userId(),callback)->
    check payload,Object
    check userId,String
    check @config.baseUrl,String
    check @config.auth,String
    HTTP.post("#{@config.baseUrl}/identify",{
        data:
          userId:userId
          traits:payload
          timestamp:new Date().toISOString()
        auth:@config.auth
      }
    ,(err,res)->
      _resolveResult err,res,callback

    )

  track:(event,payload,userId=Meteor.userId(),callback)->
    check payload,Object
    check event,String
    check userId,String
    check @config.baseUrl,String
    check @config.auth,String
    HTTP.post("#{@config.baseUrl}/track",{
        data:
          userId:userId
          event: event
          timestamp: new Date().toISOString()
          properties:payload
        auth:@config.auth
      }
    ,(err,res)->
      _resolveResult err,res,callback
    )


  page:(name,payload,userId=Meteor.userId(),callback)->
    check payload,Object
    check name,String
    check userId,String
    check @config.baseUrl,String
    check @config.auth,String
    HTTP.post("#{@config.baseUrl}/page",{
        data:
          userId:userId
          name:name
          timestamp:new Date().toISOString()
          properties:payload
        auth:@config.auth
      }
    ,(err,res)->
      _resolveResult err,res,callback
    )


  remove:(callback)->
    check Meteor.userId(),String
    check @config.baseUrl,String
    check @config.auth,String
    HTTP.post("#{@config.baseUrl}/remove",{
        data:
          userId:Meteor.userId()
          timestamp:new Date().toISOString()
        auth:@config.auth
      }
    ,(err,res)->
      _resolveResult err,res,callback
    )




Rp_Threads=new RpThreads()

Meteor.startup ()->
  if Rp_Threads.config.baseUrl and Rp_Threads.config.auth
    if Meteor.isServer
      Accounts.onLogin (info)->
        Rp_Threads.identify({email:info.user.emails[0].address},info.user._id,(err,res)->
          if res
            Rp_Threads.track('signIn',{email:info.user.emails[0].address},info.user._id,(err,res)->
              console.log err or res
            )
        )




