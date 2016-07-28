if Meteor.isServer
  Meteor.methods
    users_add_email: (email) ->
      if not @userId?
        return {error: true, message: "email_login_required"}
      if not email
        return {error: true, message: "email_required"}
      if not /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)
        return {error: true, message: "email_format_error"}
      if db.users.find({"emails.address": email}).count()>0
        return {error: true, message: "email_exists"}

      user = db.users.findOne(_id: this.userId)
      if user.emails? and user.emails.length > 0 
        db.users.direct.update {_id: this.userId}, 
          $push: 
            emails: 
              address: email
              verified: false
      else
        db.users.direct.update {_id: this.userId}, 
          $set: 
            steedos_id: email
            emails: [
              address: email
              verified: false
            ]

      Accounts.sendVerificationEmail(this.userId, email);

      console.log("add email " + email + " for user " + this.userId)
      return {}

    users_remove_email: (email) ->
      if not @userId?
        return {error: true, message: "email_login_required"}
      if not email
        return {error: true, message: "email_required"}

      user = db.users.findOne(_id: this.userId)
      if user.emails? and user.emails.length >= 2
        p = null
        user.emails.forEach (e)->
          if e.address == email
            p = e
            return
        
        db.users.direct.update {_id: this.userId}, 
          $pull: 
            emails: 
              p
      else
        return {error: true, message: "email_at_least_one"}

      console.log("remove email " + email + " for user " + this.userId)
      return {}

    users_verify_email: (email) ->
      if not @userId?
        return {error: true, message: "email_login_required"}
      if not email
        return {error: true, message: "email_required"}
      if not /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)
        return {error: true, message: "email_format_error"}
      

      Accounts.sendVerificationEmail(this.userId, email);

      console.log("verify email " + email + " for user " + this.userId)
      return {}

    users_set_primary_email: (email) ->
      if not @userId?
        return {error: true, message: "email_login_required"}
      if not email
        return {error: true, message: "email_required"}

      user = db.users.findOne(_id: this.userId)
      emails = user.emails
      emails.forEach (e)->
        if e.address == email
          e.primary = true

      db.users.direct.update {_id: this.userId},
        $set:
          emails: emails


      return {}



if Meteor.isClient
    Steedos.users_add_email = ()->
        swal
            title: t("primary_email_needed"),
            text: t("primary_email_needed_description"),
            type: 'input',
            showCancelButton: false,
            closeOnConfirm: false,
            animation: "slide-from-top"
        , (inputValue) ->
            console.log("You wrote", inputValue);
            Meteor.call "users_add_email", inputValue, (error, result)->
                if result?.error
                    toastr.error result.message
                else
                    swal t("primary_email_updated"), "", "success"

    Tracker.autorun (c) ->

        if Meteor.user()
            primaryEmail = Meteor.user().emails?[0]?.address
            if !primaryEmail
                Steedos.users_add_email();