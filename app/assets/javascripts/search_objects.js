(function () {

  'use strict';

  var hoverIndex = 0;

  function filterObjects(value) {
    var $objects = getObjects();
    var re = new RegExp(searchifyStr(value));

    var $matched = $objects.filter(function (i, object) {
      var $object = $(object);
      var text = $object.find('.js-objectItem__text').text();
      var str = searchifyStr(text);
      return re.test(str);
    });

    $objects.addClass('is-hidden');

    if ($matched.length) {
      $('.js-emptyState').addClass('is-hidden');
      return $objects.filter($matched)
        .removeClass('is-hidden');
    }

    $('.js-emptyState').removeClass('is-hidden');

    return $matched;
  }

  function hoverIndexed($visible) {
    $visible
      .removeClass('is-hovered')
      .eq(hoverIndex)
        .addClass('is-hovered')
  }

  function getObjects() {
    return $('.js-objectItem');
  }

  function handleBeforeCache() {
    var $input = $('.js-searchObjects');
    hoverIndex = 0;
    if ($input.length) $input.val('');
  }

  function handleKeydown(event) {
    var keyCode = event.keyCode;
    var $objects = getObjects();
    var $visible = $objects.filter(':not(.is-hidden)');
    var first;

    if (keyCode === 13) {
      if ($visible.length) {
        Turbolinks.visit($visible.eq(hoverIndex).data('url'));
      }
    } else if (keyCode === 38 || keyCode === 40) {
      event.preventDefault();

      if (keyCode === 38) {
        if (hoverIndex === 0) {
          hoverIndex = $visible.length - 1;
        } else {
          hoverIndex--;
        }
      } else {
        if (hoverIndex + 1 === $visible.length) {
          hoverIndex = 0;
        } else {
          hoverIndex++;
        }
      }

      hoverIndexed($visible);
    }
  }

  function handleInput(event) {
    var $matched = filterObjects(event.target.value);

    hoverIndex = 0;

    if ($matched.length) {
      hoverIndexed($matched);
    }
  }

  function searchifyStr(str) {
    return str.toLowerCase().replace(/\s/g, '');
  }

  $(function () {
    $(document)
      .on('input', '.js-searchObjects', handleInput)
      .on('keydown', '.js-searchObjects', handleKeydown)
      .on('turbolinks:before-cache', handleBeforeCache);
  });

})();
