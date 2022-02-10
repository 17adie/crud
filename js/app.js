let server_url = 'http://localhost/crud';

const app = {

  api_request: function(procedure_name, params, api, callback){
    $.ajax({
      url: server_url + '/ajax/api/'+ api +'.php',
      data: {
          procedure_name,
          params
      },

      type: 'POST',
      dataType: 'html',
      crossDomain: true,
      timeout: 50000,
      success: function(data, textStatus, xhr){

          let enc_resp = JSON.parse(data);

          if(enc_resp.error == undefined){
              return callback(enc_resp)
          }else{
              let api_error = enc_resp.error
              console.log('Failed to communicate with the server. Error code: ' + api_error.code,'Server Timeout')
          }

      },
      error: function(resp){

          console.log(resp)

      }
  });
  },

  validate_input: function (form) {
    let is_valid = true

    $('span.required',form).each(function(){
        const
            sp = $(this),
            inp = sp.next('input[type="text"]'),
            valid = function(inp,v){
                if(v){
                    inp.removeClass('custom-error')
                }else{
                    inp.addClass('custom-error')
                    is_valid = false
                }
            }
        // check blank/null value for text
        if (inp.val() === '') {
            valid(inp,0)
        } else {
            valid(inp,1)
        }
    })
    return is_valid
},

// modal body loader
loader: function(method, elem){

  $('#dv-loader').remove();
  $('<div id="dv-loader" style="padding-top:50px;padding-bottom:50px; text-align: center"><i class="fa fa-cog fa-spin" style="font-size: 35px; color:#52c306;"></i><br><br><b id="percentage-loader"></b> </div>').insertBefore($(elem));

  if(method == 'hide'){
      $('#dv-loader').fadeOut();
      setTimeout((function(){
          $(elem).fadeIn();
      }),1000);
  }else{
      $(elem).hide();
      $('#dv-loader').fadeIn();
  }
}
// modal body loader
  

}