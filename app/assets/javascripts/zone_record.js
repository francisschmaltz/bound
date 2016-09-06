(function () {

  'use strict';

  function handleClick(event) {
    event.preventDefault();
    var $row = $(event.currentTarget);
    Turbolinks.visit($row.data('url'));
  }

  $(function () {
    $(document).on('click', '.js-zoneRecord', handleClick);
  });

})();
