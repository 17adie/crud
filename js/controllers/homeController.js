
const main = {
  fn: {
    get_new_old_book: function(type, cb){
      const params = {
        _type: type
      };
      app.api_request('sp-get_book_new_old', params, 'crud', function (resp) {
          return cb(resp)
      })
    }
  }
}


  main.fn.get_new_old_book('new', function(resp){
    $('#new_book_pagination').pagination({
      dataSource:resp,
      pageSize: 5,
      callback: function(data, pagination) {

          if(data.length) {
            let cards = data.map( (v,i) => {
                return(`
                  <div class="col-auto mb-3">
                      <div class="card" style="width: 18rem;">
                          <img class="card-img-top" src="images/book_cover_sample.png" alt="Book Cover">
                          <div class="card-body">
                              <h5 class="card-title">${v.title}</h5>
                              <h6 class="card-subtitle mb-2 text-muted font-italic">${v.author}</h6>
                              <div class="book_details">
                                <p>Category : <span>${v.category}</span></p>
                                <p>Publisher : <span>${v.publisher}</span></p>
                                <p>Year Published : <span>${v.year_published}</span></p>
                                <p>ISBN : <span>${v.isbn}</span></p>
                              </div>
                          </div>
                      </div>
                  </div>
                `)
              })
      
            $('div.new_book-results-card').html(cards)
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
          } else {
            
            let no_result = `<div class="no_data_found">No New Books</div>`

            $('div.new_book-results-card').html(no_result)

          }
      }
    })  
  })
  
  main.fn.get_new_old_book('old', function(resp){
    $('#old_book_pagination').pagination({
      dataSource:resp,
      pageSize: 6,
      callback: function(data, pagination) {

          if(data.length) {
            let cards = data.map( (v,i) => {
                return(`
                  <div class="col-auto mb-3">
                      <div class="card" style="width: 18rem;">
                          <img class="card-img-top" src="images/book_cover_sample.png" alt="Book Cover">
                          <div class="card-body">
                              <h5 class="card-title">${v.title}</h5>
                              <h6 class="card-subtitle mb-2 text-muted font-italic">${v.author}</h6>
                              <div class="book_details">
                                <p>Category : <span>${v.category}</span></p>
                                <p>Publisher : <span>${v.publisher}</span></p>
                                <p>Year Published : <span>${v.year_published}</span></p>
                                <p>ISBN : <span>${v.isbn}</span></p>
                              </div>
                          </div>
                      </div>
                  </div>
                `)
              })
      
            $('div.old_book-results-card').html(cards)
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
          } else {
            
            let no_result = `<div class="no_data_found">No Old Books</div>`

            $('div.old_book-results-card').html(no_result)

          }
      }
    })  
  })


