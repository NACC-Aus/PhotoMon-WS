function rotateImg(img, direction){
  var classes = img.attr('class');
  if(typeof classes == "undefined"){
    classes = "";
  }

  $(classes.split(' ')).each(function() { 
    if (this.toString().indexOf("rotate") == 0) {
      img.removeClass(this.toString());
    }
  });

  var angle = parseInt($("#angle").val());
  if(direction == "left"){
    if(angle == 0){
      angle = 360;
    }
    angle = (angle-90)%360;
  }else{
    angle = (angle+90)%360;
  }

  $("#angle").val(angle);
  img.addClass("rotate"+angle);
}

$(document).on('rails_admin.dom_ready', function(){ 
  
  if($("p.photo-status").length > 0){
    $("p.photo-status").each(function(i, e){
      if($(e).data("isGuide") == "1"){
        $(e).closest("tr").addClass("guide-photos");
      }else if($(e).data("status") == "accepted"){
        $(e).closest("tr").addClass("accepted-photos");
      }
    })
  }

  var img = $('#photo-view');
  if(img.length > 0){
    document.getElementById('rotate-left').onclick = function() {
      rotateImg(img, "left");
    }

    document.getElementById('rotate-right').onclick = function() {
      rotateImg(img, "right");
    }
  }

  $(".view_member_link").find("a").removeClass("pjax").attr("target", "_blank");

  // Fix sort icon for datetime_type column
  $.each($(".datetime_type"), function(i, ele){
    if($(ele).hasClass("headerSortUp")){
      $(ele).removeClass("headerSortUp").addClass("headerSortDown");
    }else if($(ele).hasClass("headerSortDown")){
      $(ele).removeClass("headerSortDown").addClass("headerSortUp");
    }
  });
});