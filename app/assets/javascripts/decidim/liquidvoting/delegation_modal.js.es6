$(() => {
  $('#delegation-form').submit(function() {
    if ($( "#select-delegate option:selected" ).text() == $('#delegation-submit').data('default-select')) {
      alert($('#delegation-submit').data('select-alert'));
      return false; // prevent the form submit
    }
  });
});
