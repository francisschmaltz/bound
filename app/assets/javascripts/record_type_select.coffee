$(document).on 'turbolinks:load', ->

  setRecordTypeForForm = ($form, type)->
    $allTypeAreas = $('[data-type]')
    $allTypeAreas.hide()
    $allTypeAreas.find('select, input, textarea').prop('disabled', true)

    $specificField = $("[data-type='#{type}'")
    $specificField.show()
    $specificField.find('select, input, textarea').prop('disabled', false)

  $(document).on 'change', '.js-record-type-select', ->
    setRecordTypeForForm($(this).parents('form'), $(this).val())

  $select = $('.js-record-type-select')
  if $select.length
    setRecordTypeForForm($select.parents('form'), $select.val())
