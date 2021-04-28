$(() => {
  $('#delegation-form').submit(function()
    {
      if ($( "#select-delegate option:selected" ).text() == "(choose delegate)") {
        // 'event' in command below is, apparently, deprecated, but this does not work in Chromium
        // without it. Needs more investigation.
        event.preventDefault(); // This will prevent the form submit
        alert('You must select a delegate!');
        return false; // prevent the form submit (for IE)
      }
    });
});
