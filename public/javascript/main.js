var clicked = false
$('#searchbutton').click(function(e){
  e.preventDefault();
  $('.container').removeAttr('id')

  if(clicked===false){
    clicked = true
    $(".loading_div").fadeIn(2000);
    $.get('/search',$('#gimmesongs').serialize(),function(response){
      $(".loading_div").fadeOut(1000);
      $('.container').html(response).removeAttr('id')
    })
  }
})
$('.leftBar').hover(function(){
  $(this).stop().animate({left: "0em"},'fast');
}, function(){
  $(this).stop().animate({left: "-13em"},1000);
})
$('#savebutton').click(function(e){
  e.preventDefault();
  $.post("/saveplaylist", $("#save_playlist").serialize(), function(response){
      $("#savebutton").attr('value', 'Saved!')
      $("#savebutton").css('color','#949494')
      $('#playlist-selector').append("<option>" + response + "</option>")
    })
})

$('#playlist-selector').change(function(e){
  e.preventDefault();
  $('.container').removeAttr('id')
  $.get("/search", $('#playlist-select-form').serialize(), function(response){
    $('.container').html(response).removeAttr('id')
  })
})
