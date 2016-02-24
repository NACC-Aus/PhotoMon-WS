/** 
* Upload photos
* @author DatPB
**/
function uploadPhoto(form_id, field_date_id, field_photo_id) {
  this.form_id = form_id;
  this.field_date_id = field_date_id;
  this.field_photo_id = field_photo_id;

  this.templates = {
    file: function(id){
      return '<input data-fileupload="true" id="' + id + '" multiple="true" name="photo[image][]" type="file">';
    },

    date: '<input id="photo_date" multiple="true" name="photo[date][]" type="text">'
  }

  /**
  * Init
  **/
  this.init = function(){
    this.init_events();
  }

  /**
  * 
  **/
  this.init_events = function(){
    this.init_file_change_events();
  }

  /**
  * File change event
  **/
  this.init_file_change_events = function(){
    var self = this;

    $(document).delegate(this.field_photo_id, "change", function(ev){ 
      files = ev.target.files;

      $(this).closest(".toggle").find(".preview").remove();

      var photo_dates = [];
      $.each(files, function(i, e){
        date = e.lastModifiedDate + "";
        photo_dates.push(date);

        $("<img class='preview' src='' id='photo_preview_" + i + "' style='padding-right: 15px; padding-bottom: 15px;'>").insertBefore($(self.field_photo_id));
        var reader = new FileReader();

        reader.onload = function (eve) {
          $("#photo_preview_" + i).attr('src', eve.target.result);

          var b64 = String(eve.target.result);
          var bin = atob( b64.split( ',' )[1] ); // convert base64 encoding to binary
          var exif = EXIF.readFromBinaryFile( new BinaryFile( bin ) );

          try{
            if (exif && (exif.DateTimeOriginal || exif.DateTime)){
              date = exif.DateTimeOriginal || exif.DateTime;
              tmp = date.split(" ");
              tmp[0] = tmp[0].split(":").join("-");
              date = new Date(tmp[0] + "T" + tmp[1]);

              photo_dates[i] = date;
              $(self.field_date_id).val(photo_dates.join(","));
            }
          }catch(e){

          }
        }

        reader.readAsDataURL(e);
      });

      $(self.field_date_id).val(photo_dates.join(","));
    });
  }
}

$(function(){
  var bulk_files_upload = new uploadPhoto("#bulk_files_upload", "#bulk_files_upload #photo_date", "#bulk_files_upload #photo_image");
  bulk_files_upload.init();

  var new_photo = new uploadPhoto("#new_photo", "#new_photo #photo_created_at", "#new_photo #photo_image");
  new_photo.init();
});