//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

(function () {

  'use strict';

  var $outlet;

  function handleModalSuccess(event, response) {
    var $modal = $(response);
    $outlet.append($modal);
  }

  $(function () {
    $outlet = $('.js-outlet');
    $(document).on('ajax:success', '.js-modal', handleModalSuccess);
  });

})();
