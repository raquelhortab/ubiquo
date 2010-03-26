var CategorySelector = Class.create({
  initialize: function(link) {
    this.new_element_link = link;
    var link_id = link.id.gsub('link_new_', '');
    this.type = link_id.split('_')[0];
    this.object_name = link_id.split('_')[1];
    this.key = link_id.split('_')[2];
  },
  counter: function() {
    return this.new_element_link.up().previous('ul').select('li').size();
  },
  add_element: function(input_id) {
    var element_input = $(input_id);
    if (element_input.value != "") {
      if (this.type == "checkbox") {
        var element = "<li><input type='"+this.type+"' checked='checked' value='"+element_input.value+"' id='new_"+this.object_name+"_"+this.key+"_"+this.counter()+"' name='"+this.object_name+"["+this.key+"][]' />";
        element += "<label for='new_"+this.object_name+"_"+this.key+"_"+this.counter()+"'>"+element_input.value+"</label></li>";
        element_input.up().up().previous('ul').insert(element);
        this.toggle_new_category_input(element_input.up().previous('.category_selector_new'));
      } else if (this.type == "select") {
        var select = $(this.object_name + "_" + this.key + "_select");
        var option = document.createElement('option');
        option.text = element_input.value;
        option.value = element_input.value;
        option.selected = "selected";
        select.options.add(option);
        this.toggle_new_category_input(element_input.up().previous('.category_selector_new'));
      }
    }
  },
  toggle_new_category_input: function(link) {
    $("new_" + this.object_name + "_" + this.key).value = "";
    link.next('.add_new_category').toggle();
  }
});
document.observe("dom:loaded", function() {
  $$('.category_selector_new').each(function(link) {
    var selector = new CategorySelector(link);
    link.observe(
      "click",
      function(event) {
        selector.toggle_new_category_input(link);
        event.stop();
      }
    );
    $$('.add_new_category_link').each(function(add_link) {
      add_link.observe(
        "click",
        function(event) {
          selector.add_element("new_" + selector.object_name + "_" + selector.key);
          event.stop();
        }
      );
    });
  });
});
