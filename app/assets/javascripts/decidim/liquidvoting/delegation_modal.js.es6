$(() => {
  $('#delegation-form').submit(function() {
    var submit = $('#delegation-submit');

    if ($( "#select-delegate option:selected" ).text() == submit.data('default-select')) {
      alert(submit.data('select-alert'));
      return false; // prevent the form submit
    }
  });
});
