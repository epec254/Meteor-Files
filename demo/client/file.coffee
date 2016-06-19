Template.file.onCreated ->
  @fetchedText = new ReactiveVar false
  @showInfo    = new ReactiveVar false
  @warning     = new ReactiveVar false

Template.file.onRendered ->
  @warning.set false
  @fetchedText.set false
  @data.file = @data.file.fetch()?[0]
  if @data.file and (@data.file.isText or @data.file.isJSON)
    self = @
    HTTP.call 'GET', Collections.files.link(@data.file), (error, resp) ->
      if error
        console.error error
      else
        if !~[500, 404, 400].indexOf resp.statusCode
          if resp.content.length < 1024 * 64
            self.fetchedText.set resp.content
          else
            self.warning.set true

Template.file.helpers
  warning:     -> Template.instance().warning.get()
  getCode:     -> if @type and !!~@type.indexOf('/') then @type.split('/')[1] else ''
  isBlamed:    -> !!~_app.blamed.get().indexOf(@_id)
  showInfo:    -> Template.instance().showInfo.get()
  fetchedText: -> Template.instance().fetchedText.get()

Template.file.events
  'click #blame': (e) ->
    e.preventDefault()
    blamed = _app.blamed.get()
    if !!~blamed.indexOf(@_id)
      blamed.splice blamed.indexOf(@_id), 1
      _app.blamed.set blamed
      Meteor.call 'unblame', @_id
    else
      blamed.push @_id
      _app.blamed.set blamed
      Meteor.call 'blame', @_id
    return false

  'click #showInfo': (e, template) ->
    e.preventDefault()
    template.showInfo.set !template.showInfo.get()
    return false