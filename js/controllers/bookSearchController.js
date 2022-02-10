Ladda.bind('.ladda-button')

const main = {
  fn: {
    search_book: function(search_string, cb){
      const params = {
        _search_string: search_string
      };
      app.api_request('sp-get_book', params, 'crud', function (resp) {
          return cb(resp)
      })
    }
  }
}


$(document)

.off('click', '#btn-search_book').on('click', '#btn-search_book', function(){
  
  let search = $('#search_value').val()

  main.fn.search_book(search, function(resp){
    $('#book_pagination').pagination({
      dataSource:resp,
      pageSize: 9,
      callback: function(data, pagination) {
          console.log(data)
          console.log(data.length)

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
      
            $('div.book-results-card').html(cards)
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            Ladda.stopAll()
          } else {
            
            let no_result = `<div class="no_data_found">No Data Found</div>`

            $('div.book-results-card').html(no_result)

          }
  
          
      }
  })
  
  })
  
})


