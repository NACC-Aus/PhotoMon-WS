/**
* Device::Session module
**/
var DeviseSession = {
  /**
  * #login_page
  **/
  init: function(){
    this.login_page = $("#login_page");
    this.login_form = this.login_page.find("form#new_user");

    this.init_events();
  },

  /**
  * 
  **/
  init_events: function(){
    var self = this;

    if(self.login_page.length > 0){
      self.sign_in_form_validation();

      self.login_form.submit(function(e){
        return $(this).valid();
      });
    }
  },

  /**
  * 
  **/
  sign_in_form_validation: function(){
    this.login_form.validate({
      highlight: function (element) {
        jQuery(element).closest('.form-group').removeClass('has-success').addClass('has-error');
      },
      success: function (element) {
        jQuery(element).closest('.form-group').removeClass('has-error');
      },
      rules: {
        "user[email]": {
          required: true,
          email: true
        },
        "user[password]": {
          required: true
        }
      },
      errorElement: 'span',
      errorClass: 'help-block jq-validate-error',
      errorPlacement: function (error, element) {
        if (element.parent('.input-group').length) {
          error.insertAfter(element.parent());
        } else if (element.prop('type') === 'checkbox') {
          error.appendTo(element.closest('.checkbox').parent());
        } else if (element.prop('type') === 'radio') {
          error.appendTo(element.closest('.radio').parent());
        }
        else {
          error.insertAfter(element);
        }
      }
    });
  }
}


$(function() {
  DeviseSession.init();
});