function toggle_element(checkbox, name) {
  if(checkbox.checked){
    $(name).ancestors().first().show();
  }else{
    $(name).ancestors().first().hide();
  }
}
 
//remove de div with the id div_name
function  remove_nested_association(link){
  $(link).previous("input[type=hidden][name~_destroy]").value = "1";
  $(link).ancestors('div.nested').first().hide();
}

function add_nested_association(link, association) {
  if(!window.nested_forms_cache){
    window.nested_forms_cache = {};
  }
  if(window.nested_forms_cache && window.nested_forms_cache[association]){
    add_nested_association_fields(link, association, window.nested_forms_cache[association]);
  }else{
    new Ajax.Request('nested_fields',
    {
      method:'get',
      parameters: {"association": association},
      onSuccess: function(transport){
        window.nested_forms_cache[association] = transport.responseText;
        add_nested_association_fields(link, association, transport.responseText)
      }
    });
  }
}

function add_nested_association_fields(link, association, content){
  var new_id = new Date().getTime();
  var new_content = content;
  var regexs = [
    "("+association + "_attributes_)(\\d+)_",
    "("+association + "_attributes\\]\\[)(\\d+)\\]"
  ];
  regexs.each(function(regex, index) {
    new_content.match(new RegExp(regex));
    new_content = new_content.gsub(RegExp.$1+RegExp.$2, RegExp.$1 +new_id);
  })
  $(link).up().insert({
    after: new_content
  });
  syncMenuLinkableSettings();
}


function addMenuClickHandler() {
  $$('.accordion-toggle').each(function(item) {
    item.observe('click', function() {
      $('widget_menu_id').value = item.id;
    });
  });
}

function syncMenuLinkableSettings(){
  var link_type_selectors;
  if($(this).name != ''){
    link_type_selectors = [$(this)];
  } else{
    // this is the window, so we will compute for all link_type selectors
    link_type_selectors = $$('.menu_item_link_type');
  }
  $(link_type_selectors).each(function(link_type_selector){
    var form_item = $(link_type_selector).up('.form-item');
    if(form_item){
      var link_options = form_item.down('.link_options');
      if(link_options){
        link_options.childElements().each(function(e){
          $(e).hide();
        })

        var value = $(link_type_selector).value;
        var element = $(form_item).down('.menu_item_' + value.toLowerCase() + '_link');
        if(element){
          $(element).show();
        }
      }
    }
  })
}
