$(() => {
  $('#delegation-form').submit(function() {
    if ($( "#select-delegate option:selected" ).text() == "(choose delegate)") {
      alert("Please first choose your delegate");
      return false; // prevent the form submit
    }
  });
});
