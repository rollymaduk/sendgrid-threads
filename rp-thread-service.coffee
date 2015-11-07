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
    options=data:{userId:userId,traits:payload,timestamp:new Date().toISOString()},auth:@config.auth
    if callback
      HTTP.post("#{@config.baseUrl}/identify",options,(err,res)->_resolveResult err,res,callback)
    else
      HTTP.post("#{@config.baseUrl}/identify",options)


  track:(event,payload,userId=Meteor.userId(),callback)->
    check payload,Object
    check event,String
    check userId,String
    check @config.baseUrl,String
    check @config.auth,String
    options=data:{userId:userId,event: event,timestamp: new Date().toISOString(),properties:payload},auth:@config.auth
    if callback
      HTTP.post("#{@config.baseUrl}/track",options,(err,res)->_resolveResult err,res,callback)
    else
      HTTP.post("#{@config.baseUrl}/track",options)


  page:(name,payload,userId=Meteor.userId(),callback)->
    check payload,Object
    check name,String
    check userId,String
    check @config.baseUrl,String
    check @config.auth,String
    options=data:{userId:userId,name:name,timestamp: new Date().toISOString(),properties:payload},auth:@config.auth
    if callback
      HTTP.post("#{@config.baseUrl}/page",options,(err,res)->_resolveResult err,res,callback)
    else
      HTTP.post("#{@config.baseUrl}/page",options)



  remove:(callback)->
    check Meteor.userId(),String
    check @config.baseUrl,String
    check @config.auth,String
    options=data:{userId:userId,timestamp: new Date().toISOString()},auth:@config.auth
    if callback
      HTTP.post("#{@config.baseUrl}/remove",options,(err,res)->_resolveResult err,res,callback)
    else
      HTTP.post("#{@config.baseUrl}/remove",options)



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




