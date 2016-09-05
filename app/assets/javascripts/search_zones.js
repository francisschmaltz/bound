(function () {

  'use strict';

  function filterZones(value) {
    var $zones = getZones();
    var re = new RegExp(searchifyStr(value));

    var $matched = $zones.filter(function (i, zone) {
      var $zone = $(zone);
      var text = $zone.find('.js-zoneItem__desc').text();
      var str = searchifyStr(text);
      return re.test(str);
    });

    $zones.addClass('is-hidden');

    if ($matched.length) {
      $('.js-emptyState').addClass('is-hidden');
      return $zones.filter($matched)
        .removeClass('is-hidden');
    }

    $('.js-emptyState').removeClass('is-hidden');
  }

  function getZones() {
    return $('.js-zoneItem');
  }

  function handleInput(event) {
    filterZones(event.target.value);
  }

  function searchifyStr(str) {
    console.log(str);
    return str.toLowerCase().replace(/\s/g, '');
  }

  $(function () {
    $(document).on('input', '.js-searchZones', handleInput);
  });

})();
