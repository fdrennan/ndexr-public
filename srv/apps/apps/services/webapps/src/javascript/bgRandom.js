shinyjs.bgRandom = function(params){

  const divs = document.getElementsByTagName('div');
   
  for (let i = 0; i < divs.length; i++) {
    divs[i].classList.add('color-div')
  };  

  $(document).ready(function(){
    var colors = ['red','blue','green','yellow','cyan','orange'];
    $('.color-div').each(function(){
      var new_color = colors[Math.floor(Math.random()*colors.length)];
      $(this).css('background-color',new_color);
  });
});

};
