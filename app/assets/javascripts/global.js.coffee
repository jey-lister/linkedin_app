#The below code will show ajax loader for each ajax request and will hide the loader after the response
#And this will add csrf meta keyword in each request
->
  $('#loader').hide()
  $(document).ajaxStart ->
    $('#loader').show()

  $(document).ajaxError ->
    alert("Something went wrong...")
    $('#loader').hide()

  $(document).ajaxStop ->
    $('#loader').hide()

  $.ajaxSetup(
    beforeSend: (xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
  );

# As we are using data turbo links option, the page load will be differ from the normal http page loading
# The below two methods will show the ajax loder when clicking any links on the page, and will hide the loader after the page successfully arrived.
$(document).on "page:fetch", ->
  $('#loader').show()

$(document).on "page:receive", ->
  $('#loader').hide()