(function () {

  'use strict';

  function handleChange(event) {
    var $select = $(event.target);
    var $form = $select.closest('form');
    setRecord($form, $select.val());
  }

  function setRecord($form, type) {
    var $types = $('[data-type]');
    var $target = $('[data-type="' + type + '"]');

    $types.filter(function (index, type) {
      var $type = $(type);
      var isTarget = $type.is($target);
      $type
        .toggle(isTarget)
        .find('input, select, textarea')
          .prop('disabled', !isTarget)
    });
  }

  $(function () {

    var $document = $(document);

    $document
      .on('change', '.js-record-type-select', handleChange)
      .on('turbolinks:load', function () {
        var $select = $('.js-record-type-select');
        if ($select.length) {
          setRecord($select.closest('form'), $select.val())
        }
      });

  });

})();
