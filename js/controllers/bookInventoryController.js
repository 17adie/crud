let new_book = false;

Ladda.bind('.ladda-button')

const main = {
  el: {
    tbl: {
      book: '#books_tbl'
    },
    btn: {
      save: '#btn-add_book',
      delete: '.btn-delete_book',
      edit: '.btn-edit_book'
    },
    inp: {
      title : '#inp-title',
      isbn : '#inp-isbn',
      author : '#inp-author',
      publisher : '#inp-publisher',
      year_published : '#inp-year_published',
      category : '#inp-category',
    }
  },
  fn: {
    tbl: {
      books: function(){
        let unfiltered_rows_count;

        const columns = [
            {data: "tbl_id", title: "ID", className: 'tbl_id', sortable : false},
            {data: "title", title: "Title", className: 'title'},
            {data: "isbn", title: "ISBN", className: 'isbn'},
            {data: "author", title: "Author", className: 'author'},
            {data: "publisher", title: "Publisher", className: 'publisher'},
            {data: "year_published", title: "Year Published", className: 'year_published'},
            {data: "category", title: "Category", className: 'category'},
            {title: "Actions", className: 'td_action', sortable : false}
        ]

        $(main.el.tbl.book).dataTable({
            serverSide: true,
            lengthChange: false,
            searchDelay: 1000,
            // scrollY: 350,
            processing: true,
            language: {
                infoFiltered: "",  // filtered from n total entries datatables remove kasi mali bilang lagi kulang ng isa kapag nag a add.
                searchPlaceholder: "Enter Title, ISBN, Author, Publisher, Year Published or Category"
            },
            columns: columns,
            order: [[ 5, "desc" ]], // ORDER BY year published
            columnDefs: [
                {
                    render: function ( data, type, row ) { // wala lang to, para lang wala error. try mo alisin
                        return row.tbl_id + ' ' + row.title;
                    },
                    targets: -1
                }
            ],
            ajax: function (data, callback, settings) {

                const params = {
                    _limit_offset: data.start,
                    _search_string: data.search.value,
                    _sort_by: data.columns[data.order[0].column].data,
                    _sort_direction: data.order[0].dir

                };

                app.api_request('sp-get_all_books_filterable', params, 'get_table', function (response) {

                    let resp = response.data || [];
                   
                    if (data.draw === 1) { // if this is the first draw, which means it is unfiltered
                        unfiltered_rows_count = response._total_count;
                    }

                    let total_count = response._total_count;

                    callback({
                        draw: data.draw,
                        data: resp,
                        recordsTotal: unfiltered_rows_count,
                        recordsFiltered: total_count
                    });
                });
            },
            createdRow: function( row, data, dataIndex ) {

                $( row ).find('td:eq(-1)')
                    .html(
                        '<div>' +
                          '<a type="button" data-target="#modal-add_book" data-toggle="modal" class="btn btn-sm btn-primary btn-edit_book">' +
                          '<i class="fa fa-pencil white-icon" data-original-title="Edit" title="Edit"></i>' +
                          '</a>' +

                          '<a type="button" class="btn btn-sm btn-danger btn-delete_book ml-2">' +
                          '<i class="fa fa-remove white-icon" data-original-title="Edit" title="Edit"></i>' +
                          '</a>'  +
                        '</div>'
                    );

                $( row ).find('td:eq(-1) > div > a')
                    .attr({
                        'data-tbl_id': data.tbl_id,
                        'data-title': data.title
                    });

                // $(row).addClass('hover_cls');
            }

        });
      }
    },
    add_book: function(cb){
      const params = {
        _title: $(main.el.inp.title).val(),
        _isbn: $(main.el.inp.isbn).val(),
        _author: $(main.el.inp.author).val(),
        _publisher: $(main.el.inp.publisher).val(),
        _year_published: $(main.el.inp.year_published).val(),
        _category: $(main.el.inp.category).val()
      };
      app.api_request('sp-add_book', params, 'crud', function (resp) {
          return cb(resp)
      })
    },
    update_book: function(tbl_id, cb){
      const params = {
        _tbl_id: tbl_id,
        _title: $(main.el.inp.title).val(),
        _isbn: $(main.el.inp.isbn).val(),
        _author: $(main.el.inp.author).val(),
        _publisher: $(main.el.inp.publisher).val(),
        _year_published: $(main.el.inp.year_published).val(),
        _category: $(main.el.inp.category).val()
      };
      console.log({params})
      app.api_request('sp-update_book', params, 'crud', function (resp) {
          return cb(resp)
      })
    },
    delete_book: function(tbl_id, cb){
      const params = {
        _tbl_id: tbl_id
      };
      app.api_request('sp-delete_book', params, 'crud', function (resp) {
          return cb(resp)
      })
    },
    populate_book: function(tbl_id, cb){
      const params = {
        _tbl_id: tbl_id
      };
      app.api_request('sp-get_book_details', params, 'crud', function (resp) {
          return cb(resp)
      })
    }
  }
}

main.fn.tbl.books()

$(document)

.off('click', '#btn-add_new_book').on('click', '#btn-add_new_book', function(){
  new_book = true
  $(main.el.btn.save).html('Save')
  $('.book_inv_modal_title').html('Add New Book')
})

.off('click', main.el.btn.edit).on('click', main.el.btn.edit, function(){
  app.tbl_id =  $(this).data().tbl_id 
  new_book = false
  app.loader('show', '#modal-add_book .modal-body');
  console.log(app.tbl_id);
  main.fn.populate_book(app.tbl_id, function(resp){

    let {title, isbn, author, publisher, year_published, category} = resp[0]

    $(main.el.inp.title).val(title)
    $(main.el.inp.isbn).val(isbn)
    $(main.el.inp.author).val(author)
    $(main.el.inp.publisher).val(publisher)
    $(main.el.inp.year_published).val(year_published)
    $(main.el.inp.category).val(category)
   
    $(main.el.btn.save).html('Update')
    $('.book_inv_modal_title').html('Update Book')

    app.loader('hide', '#modal-add_book .modal-body');
    
  })

})

.off('click', main.el.btn.save).on('click', main.el.btn.save, function(){

  if(app.validate_input('#modal-add_book')){

    if(new_book) {
      main.fn.add_book( function(resp){

        resp = resp.length > 0 ? resp[0] : ''

        const is_duplicate_book = resp.is_duplicate_book

        if(is_duplicate_book){
          swal('Duplicate book','Book already exists\n' + 'Book Title: ' + is_duplicate_book , 'error')
          Ladda.stopAll()
        }else{ 
          $('#modal-add_book').modal('hide')
          swal('Book Added','New book successfully added','success')
          Ladda.stopAll()
          $(main.el.tbl.book).DataTable().draw() // refresh member table after add
        }

      })
    } else {
      // update book
      main.fn.update_book(app.tbl_id, function(resp){
        resp = resp.length > 0 ? resp[0] : ''

        const is_duplicate_book = resp.is_duplicate_book

        if(is_duplicate_book){
          swal('Duplicate book','Book already exists\n' + 'Book Title: ' + is_duplicate_book , 'error')
          Ladda.stopAll()
        }else{ 
          $('#modal-add_book').modal('hide')
          swal('Book Updated','Book successfully updated','success')
          Ladda.stopAll()
          $(main.el.tbl.book).DataTable().draw() // refresh member table after add
        }
      })

    }

  }else{
    swal('Incomplete Details','Please complete all the required info marked with (*)','warning')
    Ladda.stopAll()
  }
})

.off('click', main.el.btn.delete).on('click', main.el.btn.delete, function(){
  let {tbl_id, title} = $(this).data()
  
  swal({
    title:"Are you sure to delete this book?",
    text:"Book Title: " + title,
    type:"warning",
    showCancelButton:!0,
    confirmButtonColor:"#DD6B55",
    confirmButtonText:"Yes",
    closeOnConfirm:!1
  },function(){
    main.fn.delete_book(tbl_id, function(resp){
      swal('Book Deleted','','success');
      $(main.el.tbl.book).DataTable().draw(false) // refresh with false = to retain page when draw
    })
  })
})  

// remove class error when text have value when blur
.off('blur',':input').on('blur', ':input', function(){ 

    let val = $(this).val()

    if(val) {
      $(this).removeClass('custom-error')
    }
    
})

// reset modal content when close
$('#modal-add_book').on('hidden.bs.modal', function (e) {
  $(this)
      .find("input")
      .val('')
      .removeClass('custom-error')
      .end()
})