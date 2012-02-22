# ===================================================================
# Model describing an abstract MBean request (attribute or operation)
#

define(["backbone"],(Backbone) ->
  Base = Backbone.Model.extend(
    toJolokiaRequest: ->
      req = mbean: @get("mbean")
      req.path = @get("path") if @has("path")
      req
  )

  AttributeModel = Base.extend(
    toJolokiaRequest: ->
      ret = Base.prototype.toJolokiaRequest.call(this)
      ret.attribute = @get("attribute")
      ret
  )

  OperationModel = Base.extend(
    toJolokiaRequest: ->
      ret = Base.prototype.toJolokiaRequest.call(this)
      ret.operation = @get("operation")
      ret.arguments = @get("arguments") if @has("arguments")
      ret
  )

  {
    newAttributeRequest: (args...) -> new AttributeModel(args...)
    newOperationRequest: (args...) -> new OperationModel(args...)
  }
)

