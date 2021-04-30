$(() => {
  $('#delegation-form').submit(function() {
    if ($( "#select-delegate option:selected" ).text() == "(choose delegate)") {
      alert('You must choose a delegate!');
      return false; // prevent the form submit
    }
  });
});
